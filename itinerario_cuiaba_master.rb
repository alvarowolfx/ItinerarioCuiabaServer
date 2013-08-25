require 'wombat'
require 'nokogiri'
require 'open-uri'
require 'json'

class BussScraper
    include Wombat::Crawler
    
    base_url "http://www.cuiaba.mt.gov.br"
    path "/itinerario"
  
    linhas 'css=#pesquisa>select>option', :list
    
    def crawl
        resposta = super
        onibus = []
        for text in resposta['linhas'] do
            text = text.split('-')
            if(text.count >= 2)
                onibus.push({ linha: text[0].strip, nome: text[1].strip})        
            end
        end
        onibus
    end
end

class BussItineraryScraper
     
    def initialize(line = '031')    
        @base_url = "http://www.cuiaba.mt.gov.br"
        @doc = Nokogiri::HTML(open("#{@base_url}/itinerario?linha=#{line}"))
        @doc.css('br').each{ |br| br.replace("\n") }
        #@doc.xpath('//*[@id="volta"]/div[2]').remove
    end
    
    def crawl
        idas = []
        voltas = []
        return { ida: [], volta: [] }  if(@doc.at('#ida') == nil || @doc.at('#volta') == nil)   
        
        idas = parseItinerary('#ida')
        voltas = parseItinerary('#volta')
        resposta = { ida: idas, volta: voltas}
        #puts resposta
        resposta
   end
   
   def parseItinerary(id)
     paths = []
     content = @doc.at(id).content
     content = content.gsub(/\r/,'')
     content.split(/\n/).each do |path|
       next if path.upcase == path
       path = path.gsub(/(EM OPERA.*)/,'')  
       path = path.gsub(/(Obs\..*)/,'')  
       path = path.gsub(/(OBSERVA.*)/,'')  
       path = path.gsub(/(desde.*)/,'')  
       path = path.gsub(/(a partir.*)/,'')  
       path = path.gsub(/\A\(|\)\Z/,'') if path.start_with?('(')
       path = path.strip
       paths.push path if !path.empty?
     end
     paths          
   end
end

onibus = BussScraper.new.crawl

for buss in onibus do
    puts "Getting itineray for line #{buss[:linha]}"    
    scraper = BussItineraryScraper.new(buss[:linha])
    buss[:itinerario] = scraper.crawl
end

File.open("temp.json","w") do |f|
  f.write(onibus.to_json)
end
