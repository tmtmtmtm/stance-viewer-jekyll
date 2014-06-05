class Issue

  require 'json'

  @@datafile = 'stancer.json'
  #FIXME
  @@issues = JSON.parse(File.read('_data/issues.yaml'))

  def initialize(id)
    @id = id
    @data = @@issues.find { |i| i['id'] == id }
    raise "No such issue (#{id})" if @data.nil?
  end

  def aspects
    @data['aspects']
  end

  def motion_ids
    aspects.map { |a| a['motion_id'] }
  end

  def aspect_for(motionid)
    aspects.find { |a| a['motion_id'] == motionid }
  end

end

class Stance

  require 'open-uri/cached'
  OpenURI::Cache.cache_path = '/tmp/.open_uri_cache'

  @@SERVER = 'http://localhost:5000'
  @@API    = '/api/1'

  def initialize(filter, issue)
    @filter = filter
    @issue = issue
  end

  def score
    @issue.motion_ids.map { |mid| motion_score(mid) }.inject { |a, b|
      a.merge(b) { |k, aval, bval| aval + bval }
    }
  end

  def motion_score(motionid)
    aspect = @issue.aspect_for(motionid) or raise "No votes on #{motionid}" 
    weights = aspect['weights']

    agg_match = aggregate.detect { |a| a['motion_id'] == motionid }
    return { 
      num_votes: 0,
      score: 0,
      max: 0
    } if agg_match.nil?

    votes     = agg_match['counts']

    # TODO test if this matches the results
    num_votes = votes.values.map(&:to_i).reduce(:+)
    max_score = weights.values.max * num_votes
    score = votes.map { |option, count| weights[option] * count }.reduce(:+)

    return { 
      # weights: weights,
      # votes: votes,
      num_votes: num_votes,
      score: score,
      max: max_score,
    }
  end

  private
  def aggregate
    aggregate_json['aggregate']
  end

  def aggregate_url
    @@SERVER + @@API + "/aggregate?" + URI.encode_www_form(motion: @issue.motion_ids, filter: @filter)
  end

  def aggregate_txt
    @agg_txt ||= open(aggregate_url).read
  end

  def aggregate_json
    JSON.parse(aggregate_txt)
  end

end
