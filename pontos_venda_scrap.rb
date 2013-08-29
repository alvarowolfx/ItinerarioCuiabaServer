require 'nokogiri'
require 'open-uri'
require 'json'

class PointsOfChargeScraper
     
    def initialize()    
        base_url = "http://www.amtu.com.br/Cartao/0,0,0,0,0,10/Pontos_de_Recarga.html"
        @doc = Nokogiri::HTML(open(base_url))
    end
    
    def crawl
        links = []
        reg = Regexp.new(/javascript: PopUp\(\'(?<link>.*)/)
        @doc.css('a').each do |a|
            if reg.match(a['href']) then
                link = a['href'].gsub(reg,'\k<link>')
                link = link.split('\'')[0]
                #puts link
                link = link.split('/')[0...-1].join('/') + '/blabla.html'
                links.push link
            end
        end
        links.uniq
   end
   
end

class PointGeocodeScraper
     
    def initialize(url)    
        @doc = Nokogiri::HTML(open(url))
    end
    
    def crawl
        name = @doc.at('h1').content
        @doc.css('h1').each{ |br| br.replace("<h1>#{br.content}</h1>\n") }
        address = @doc.at('td').content.split("\n")[1]
        iframe = @doc.at('iframe')
        if iframe != nil then
            src = iframe['src'][/&ll=(.*?)&/,1]
        end
        if src != nil then
            loc = src.split(',')
            loc = {:lat =>  loc[0], :lon => loc[1] }
        end
        { :location => loc, :name => name, :address => address }
   end
   
end

links = PointsOfChargeScraper.new.crawl
points = [];
for link in links do
    puts "Getting link : #{link}"
    result = PointGeocodeScraper.new(link).crawl
    puts result
    points.push result
end

File.open("points_of_charge.json","w") do |f|
  f.write(points.to_json)
end