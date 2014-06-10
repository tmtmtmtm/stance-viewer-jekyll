#!/usr/bin/ruby

# Usage: ruby -Ilib _bin/make_mp_stances.rb > _data/mpstances.yaml

require 'json'
require 'stancer'
require 'parallel'
require 'colorize'

issues = JSON.parse(File.read('_data/issues.yaml'))
parties = JSON.parse(File.read('_data/parties.yaml'))

allstances = []
errors = []

Parallel.each(issues, :in_threads => 10) do |i|
  begin
    stances = parties.map { |p|
      warn "Calculating #{i['text']} (#{i['id']}) for #{p['name']}"
      Aspect.new(
        bloc:'voter.id',
        filter: "party.id:#{p['id']}",
        issue: Issues.new('_data/issues.yaml').issue(i['id']),
      ).scored_blocs
    }.reduce(:merge)
    
    i['stances'] = stances
    allstances << i
  rescue => e
    msg = "PROBLEM with #{i['text']} (#{i['id']}) = #{e}"
    errors << msg
    warn "#{msg}.red"
  end
end

puts JSON.pretty_generate(allstances)

errors.each do |msg| 
  warn "#{msg}".yellow
end
