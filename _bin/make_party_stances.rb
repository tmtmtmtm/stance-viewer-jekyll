#!/usr/bin/ruby

require 'json'
require 'stancer'

issues = JSON.parse(File.read('_data/issues.yaml'))

allstances = issues.map do |i|
  i['stances'] = Aspect.new(
    bloc:'party.id',
    issue: Issue.new(i['id']),
  ).scored_blocs
  i
end

puts JSON.pretty_generate(allstances)
