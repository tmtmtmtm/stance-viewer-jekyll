#!/usr/bin/ruby

# Usage: ruby -Ilib _bin/make_party_stances.rb > _data/partystances.yaml

require 'json'
require 'stancer'
require 'parallel'

issues = JSON.parse(File.read('_data/issues.yaml'))

allstances = Parallel.map(issues, :in_threads => 5) do |i|
  warn "Generating stance on #{i['id']}"
  i['stances'] = Aspect.new(
    bloc:'party.id',
    issue: Issue.new(i['id']),
  ).scored_blocs
  i
end

puts JSON.pretty_generate(allstances)
