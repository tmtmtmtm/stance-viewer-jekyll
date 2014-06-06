#!/usr/bin/ruby

require 'json'
require 'stancer'
require 'parallel'

issues = JSON.parse(File.read('_data/issues.yaml'))
parties = JSON.parse(File.read('_data/parties.yaml'))

allstances = []

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
    }.reduce(:merge).map { |k, v| { person: k, scores: v.merge({ weight: v[:num_votes].zero? ? 0.5 : v[:score] / v[:max] }) } }
    
    i['stances'] = stances
    allstances << i
  rescue => e
    warn "PROBLEM with #{i['text']} (#{i['id']}) = #{e}"
  end
end

puts JSON.pretty_generate(allstances)
