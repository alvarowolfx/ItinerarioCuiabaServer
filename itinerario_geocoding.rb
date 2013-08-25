require 'json'
require 'fileutils'

onibus = {}
File.open("temp.json","r") do |f|
  onibus = JSON.load(f)
end
ruas = []
for buss in onibus do
    for path in (buss['itinerario']['ida'] + buss['itinerario']['volta']).uniq do
        ruas.push path
    end
end
ruas = ruas.uniq

puts ruas.count
#puts ruas.join(',')
puts ruas

#puts FileUtils.compare_file('temp.json','temp2.json')

for buss in onibus do
    #puts buss['itinerario']['volta'].last
end
