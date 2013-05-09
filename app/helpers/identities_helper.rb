
module IdentitiesHelper
  
  # from http://stackoverflow.com/questions/1065320/in-rails-display-time-between-two-dates-in-english
  def time_span_in_natural_language(time_span)
    distance_in_seconds = (time_span.abs).round
    components = []

    %w(year month week day).each do |interval|
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
