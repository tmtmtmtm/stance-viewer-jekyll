class Issues
  
  def initialize(filename)
    @filename = filename
    @issues = JSON.parse(File.read(@filename))
  end

  def issue(id)
    found = @issues.detect { |i| i['id'] == id }
    raise "No such issue (#{id})" if found.nil?
    Issue.new(found)
  end
  
end

class Issue
  require 'json'

  def initialize(data)
    @data = data
  end

  def aggregate_on (hash)
    (@__a ||= {})[hash] = Aspect.new( { issue: self }.merge hash)
  end

  def aspects
    @data['aspects']
  end

  def motion_ids
    aspects.map { |a| a['motion_id'] }
  end

  def aspect_for(motionid)
    aspects.detect { |a| a['motion_id'] == motionid }
  end

end


class Aspect
  # weightable aggregate

  # TODO: issue / motion / filter / bloc
  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    raise "Need an issue" if @issue.nil?
    @motion = @issue.motion_ids if @motion.nil?
  end

  def aggregate
    @__agg ||= Aggregate.new(bloc: @bloc, filter: @filter, motion: @motion)
  end

  def weighted_blocs
    @__wb ||= Hash[ 
      aggregate.bloc_aggregates.map { |bloc, aggs|
        [ bloc,  aggs.map { |ai| weighted_aggregate(ai) } ]
      }
    ]
  end

  def scored_blocs
    # combined_blocs + weight (must add at end, as can't be summed)
    sb = __combined_blocs
    # TODO this only works when vote ranges are 0..max
    # FIXME for negatives, or other ranges, by calculating min_score too
    return Hash[ sb.map { |k, v|
      [k, v.merge({ weight: v[:num_votes].zero? ? 0.5 : v[:score] / v[:max] })]
    }]
  end

  def score(bloc=nil)
    sb = scored_blocs
    return sb[bloc] unless sb.empty?
    # TODO I don't like hard-coding this here. It should just sum as
    # normal, but to zero
    return {
      num_votes: 0,
      score: 0,
      max: 0,
    }
  end


  private
  # score a given aggregate by looking up the weights for that motion in
  # the given Issue
  def weighted_aggregate (ai)
    motionid = ai['motion_id']
    aspect = @issue.aspect_for(motionid) or raise "No votes on #{motionid}" 
    weights = aspect['weights']

    votes     = ai['counts']
    num_votes = votes.values.map(&:to_i).reduce(:+)
    max_score = weights.values.max * num_votes
    score = votes.map { |option, count| weights[option] * count }.reduce(:+)

    return { 
      num_votes: num_votes,
      score: score,
      max: max_score,
    }
  end

  # { num:1, score:10, max:20 } + {num:2, score:4, max:30} 
  #   = {num:3, score:14, max:50}
  def __combined_blocs
    @__cb ||= Hash[
      weighted_blocs.map { |bloc,waggs|
        [ bloc, waggs.each.inject { |a, b| a.merge(b) { |k, aval, bval| aval + bval } } ]
      }
    ]
  end

end

class Aggregate

  require 'open-uri/cached'
  OpenURI::Cache.cache_path = '/tmp/cache'

  @@SERVER = 'http://localhost:5000'
  @@API    = '/api/1'

  # TODO: restrict to motion / filter / bloc
  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def bloc_aggregates
    bloc_keys = blocs
    abort "Can't handle multi-blocs yet" if bloc_keys.size > 1
    aggregates.group_by { |ai| ai['bloc'][bloc_keys.first] }
  end

  def blocs
    aggregate_json['request']['blocs'].reject(&:empty?)
  end

  private
  def aggregates
    @__agg ||= aggregate_json['aggregate'] 
  end

  def aggregate_url
    @@SERVER + @@API + "/aggregate?" + URI.encode_www_form(motion: @motion, filter: @filter, bloc: @bloc)
  end

  def aggregate_txt
    @__txt ||= open(aggregate_url).read
  end

  def aggregate_json
    @__json ||= JSON.parse(aggregate_txt)
  end

end
