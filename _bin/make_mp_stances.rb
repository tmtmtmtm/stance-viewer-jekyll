#!/usr/bin/ruby

# Usage: ruby -Ilib _bin/make_mp_stances.rb > _data/mpstances.yaml

require 'json'
require 'stancer'
require 'parallel'

issues = JSON.parse(File.read('_data/issues.yaml'))
parties = JSON.parse(File.read('_data/parties.yaml'))

allstances = []

Parallel.each(issues, :in_threads => 10) do |i|
  begin
    stances = parties.map { |p|
      warn "Calculating #{i['text']} (#{i['id']}) for #{p['name']}"
      Aspect.new(
        bloc:'voter.id',
        filter: "party.id:#{p['id']}",
        issue: Issue.new(i['id']),
      ).scored_blocs
    }.reduce(:merge)
    
    i['stances'] = stances
    allstances << i
  rescue => e
    warn "PROBLEM with #{i['text']} (#{i['id']}) = #{e}"
  end
end

puts JSON.pretty_generate(allstances)
