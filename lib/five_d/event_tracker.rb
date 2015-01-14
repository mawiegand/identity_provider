require "sampl"

module FiveD
  
  class EventTracker
    include Sampl
     
    app_token 'fsRrapvL'
        
    def track(event_name, event_category, arguments)
      self.class.track(event_name, event_category, arguments)
    end

  end
end
