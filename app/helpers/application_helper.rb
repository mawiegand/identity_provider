module ApplicationHelper
  
  # creates a hash for an email address by first down-casing it,
  # as specified by the gravatar API.
  def gravatar_hash_for(email)
    return Digest::MD5.hexdigest(email.strip.downcase)
  end
  
  # creates the gravatar image tag with the side-wide default values.
  # Tag-Class and options may be overwritten by passing-in differing
  # values. 
  #
  # Possible options include (visit Gravatar for complete list):
  # [:size]    size of the created image
  # [:default] which default-icon to use, when user is not registered
  #            with gravatar (see Gravatar API for values)
  def gravatar_for(identity, css_class = 'gravatar', options = {})
    
    options = { :size => 100, :default => :identicon }.merge(options) # merge 'over' default values
    
    gravatar_image_tag(identity.email.strip.downcase, :alt      => identity.nickname,
                                                      :class    => css_class,
                                                      :gravatar => options )
  end
  
end
