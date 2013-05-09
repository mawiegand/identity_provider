module ApplicationHelper
  
  # creates the gravatar image tag with the side-wide default values.
  # Tag-Class and options may be overwritten by passing-in differing
  # values. 
  #
  # Possible options include (visit Gravatar for complete list):
  # [:size]    size of the created image
  # [:default] which default-icon to use, when user is not registered
  #            with gravatar (see Gravatar API for values)
  def gravatar_for(identity, css_class = 'gravatar', options = {})
    
    options = { 
      :size => 100, 
      :default => :identicon 
    }.merge(options).delete_if { |key, value| value.nil? }  # merge 'over' default values
    
    gravatar_image_tag(identity.email.strip.downcase, :alt      => identity.nickname,
                                                      :class    => css_class,
                                                      :gravatar => options )
  end
  
  def gravatar_img_tag_for(url, options = {})
    options = { 
      :class => 'gravatar',
      :alt => 'Gravatar',
      :src => url
    }.merge(options).delete_if { |key, value| value.nil? }  # merge 'over' default values
    
    tag 'img', options, false, false # Patch submitted to rails to allow image_tag here https://rails.lighthouseapp.com/projects/8994/tickets/2878-image_tag-doesnt-allow-escape-false-option-anymore   
  end

  # from http://stackoverflow.com/questions/1065320/in-rails-display-time-between-two-dates-in-english
  def time_span_in_natural_language(time_span)
    distance_in_seconds = (time_span.abs).round
    components = []

    %w(year month week day hour).each do |interval|
      # For each interval type, if the amount of time remaining is greater than
      # one unit, calculate how many units fit into the remaining time.
      if distance_in_seconds >= 1.send(interval)
        delta = (distance_in_seconds / 1.send(interval)).floor
        distance_in_seconds -= delta.send(interval)
        components << pluralize(delta, interval)
      end
    end

    components.join(", ")
  end

end
