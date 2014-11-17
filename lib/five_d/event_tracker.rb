require "sampl"

module FiveD
  
  class EventTracker
    include Sampl
     
    app_token 'wad-rt82-fhjk-18'
        
    def track(event_name, event_category, arguments)
      self.class.track(event_name, event_category, arguments)
    end

  end
end