module Orasaurus
  
  module Build
    
    def self.sort(arr,opts={})
      firsts = Array.new
      if tmp = Array.try_convert(opts[:first])
        firsts = opts[:first].to_ary
      elsif tmp = String.try_convert(opts[:first])
        firsts = Array.new.push(opts[:first])
      end
      
      return ( firsts + ( arr - firsts ).sort ).compact
    end
    
  end
  
end