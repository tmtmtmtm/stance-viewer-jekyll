#!/usr/bin/ruby

require 'json'
require 'stancer'
require 'parallel'

issues = JSON.parse(File.read('data.json'))
parties = JSON.parse(File.read('parties.json'))

issues.each do |i|
  begin
    stances = parties.map { |p|
      warn "Calculating #{i['text']} (#{i['id']}) for #{p['name']}"
      # Parallel.each(..., :in_threads => 10) do |i|
      Aspect.new(
        bloc:'voter.id',
        filter: "party.id:#{p['id']}",
        issue: Issue.new(i['id']),
      ).scored_blocs
    }.reduce(:merge)
    i['stances'] = stances
    puts JSON.pretty_generate(i)
  rescue
    warn "PROBLEM with #{i['text']} (#{i['id']})"
  end
end
