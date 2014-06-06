#!/usr/bin/ruby

require 'json'
require 'stancer'

issues = JSON.parse(File.read('data.json'))

issues.each do |i|
  warn "Calculating #{i['text']}"
  aspect = Aspect.new(
    bloc:'party.id',
    issue: Issue.new(i['id']),
  )
  i['stances'] = aspect.scored_blocs
  puts JSON.pretty_generate(i)
end
