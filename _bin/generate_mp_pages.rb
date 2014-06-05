#!/usr/bin/ruby

# Generate pages for each Person

require 'json'
require 'yaml'
require 'stancer'
require 'parallel'

@people  = JSON.parse(File.read('_data/people.yaml'))
@parties = JSON.parse(File.read('_data/parties.yaml'))
@issues  = JSON.parse(File.read('_data/issues.yaml'))

def dates(membership)
  return "" unless membership['start_date'] || membership['end_date']
  return [membership['start_date'], membership['end_date']].map {|s| s && s[0,4] }.join " – ".strip
end

def memberships(mp)
  mp['memberships'].map { |m|
    party = @parties.detect { |p| p['id'] == m['organization_id'] } || next
    {
      "id" => m['organization_id'],
      "name" => party['name'],
      "start" => m['start_date'],
      "end" => m['end_date'],
    }
  }.reject(&:nil?)
end

def stances(mp)
  @issues.take(10).map { |i|
    warn "Calculating #{mp['name']} stance on #{i['text']}"
    stance = Stance.new( "voter.id:#{mp['id']}", Issue.new(i['id'])).score
    {
      "id"        => i['id'],
      "title"     => i['text'],
      "text"      => i['html'],
      "score"     => stance[:score],
      "max_score" => stance[:max],
      "num_votes" => stance[:num_votes],
      # In this version, this is positive. TODO move this to the stancer
      # and cope with negatives.
      "weight"    => stance[:max].zero? ? 0 : stance[:score] / stance[:max] 
    }
  }
end

ppl = ARGV[0].nil? ? @people : @people.select { |mp| mp['id'] == ARGV[0] }
warn "Operating on #{ppl.count} ppl"

Parallel.each(ppl, :in_threads => 10) do |mp|
  filename = "person/#{mp['id']}.md"
  data = {
    "layout" => 'mp',
    "id" => mp['id'],
    "name" => mp['name'],
    "memberships" => memberships(mp),
    "stances" => stances(mp),
    "autogenerated" => true,
  }
  text = data.to_yaml + "---\n"
  warn text
  File.write(filename, text)
end
