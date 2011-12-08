module ApplicationHelper
  
  def gravatar_hash_for(email)
    return Digest::MD5.hexdigest(email.strip.downcase)
  end
  
  def gravatar_for(identity, css_class = 'gravatar', options = {})
    
    options = { :size => 100, :default => :identicon }.merge(options) # merge 'over' default values
    
    gravatar_image_tag(identity.email.strip.downcase, :alt      => identity.name,
                                                      :class    => css_class,
                                                      :gravatar => options )
  end
  
end
