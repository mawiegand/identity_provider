require "sampl"

module FiveD
  
  class EventTracker
    include Sampl
     
    app_token 'fsRrapvL'
        
    def track(event_name, event_category, arguments)
      begin
        if Rails.env.production?
          self.class.track(event_name, event_category, arguments)
        end
      rescue => e
        Rails.logger.error "ERROR EVENT_TRACKER: track did fail with exception: #{ e.message }." 
        e.backtrace.each { |line| Rails.logger.error line }
      end
    end

  end
end
