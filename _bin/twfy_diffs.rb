#!/usr/bin/ruby

# Check the scores against TWFY
# $0 <html to TWFY page>

require 'json'
require 'stancer'

@issues  = JSON.parse(File.read('_data/mpstances.yaml'))

file = ARGV[0]
mp = ARGV[1] || 'naomi_long'
check = ARGV[2] 

# distance 6677: 0.142857 -->Voted <strong>strongly for</strong> restricting the provision of services to <b>private patients</b> by the NHS<a class="dream_details" href="http://www.publicwhip.org.uk/mp.php?mpid=40068&dmp=6677">Details</a></li>

File.read(file).each_line do |line|
  next unless /distance (?<pwid>\d+): (?<pwscore>[\d\.]+) --/ =~ line
  next if check && check != pwid
  i = @issues.detect { |i| i["id"] == "PW-#{pwid}" } 
  if i.nil?
    puts "   No such issue for #{line}"
  else 
    stance = i["stances"][mp]
    (us, them) = [stance['weight'], 1-pwscore.to_f] #.map { |f| (f * 100).to_i / 100 }
    puts "   Us: #{us} vs PW: #{them} on #{pwid}: #{i["html"]}"
    if check
      puts stance
      puts line[/href="([^"]+)"/, 1]

      a = Issue.new(i['id']).aggregate_on(
        bloc:   'voter.id',
        filter: "voter.id:#{mp}",
      )
      puts JSON.pretty_generate(
        a.aggregate.bloc_aggregates.values.first.map { |m| 
          rh = { 
            motion_id: m['motion_id'], 
            vote: m['counts'].reject {|k,v| v.zero?}.keys.first,
          }
          rh[:weight] = i['aspects'].detect {|ia| ia['motion_id'] == m['motion_id'] }['weights'][rh[:vote]]
          rh
        }.sort_by { |k, v| k[:motion_id] }
      )
      
      puts a.weighted_blocs
      
    end
  end
end



