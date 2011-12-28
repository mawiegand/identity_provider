# The AttributeAuthorizationController's design goal is to provide a mechanism
# for role-based authorizing access to indiviual attributes of the controlled
# resource, where the mechanism closely resembles the interface of the 
# mass-assignment access control in ActiveModel.
class AttributeAuthorizationController < ApplicationController
    
  class_attribute :_accessible_attributes
    
  # Specifies a white list of model attributes that can be accessed by a 
  # specific role for reading and / or writing.
  #
  # A role for the attributes is optional, as well as is specifying the mode.
  # If no role is provided, then :default is used. A role can be defined by 
  # using the :as option, arbitrary symbols are acceptable. It's possible
  # to set attribute accessibility for several roles at once by passing
  # several role-symbols in an array, e.g like in:
  #  attr_access :id, :type, :name, :as => [ :default, :user, :admin ]
  #
  # If no mode is specified, :read mode is assumed. The other possible modes
  # are :create and :update mode. If attributes should be accessible in 
  # several modes, this can be achieved by passing an array, e.g. 
  # [:read, :update], or by calling attr_access several times, once for each
  # mode.
  def self.attr_access(*args)
    options = args.extract_options!
    role = options[:as]   || :default
    mode = options[:mode] || :read
    
    raise 'InvalidMode' unless Array.wrap(mode).all? { |m| [ :read, :update, :create].include? m }
    
    logger.debug(options.inspect)
    logger.debug(args.inspect)
    
    attributes_to_add = args.map { |attr| attr.to_s }  # make strings from symbols
    
    self._accessible_attributes = accessible_attributes_configs.dup  # why duplicate and re-assign? because someone else may hold the original array (e.g. in case part of it is used in this very call to attr_access)
    
    Array.wrap(role).each do | r |
      Array.wrap(mode).each do | m |
        self._accessible_attributes[r][m] = accessible_attributes(r,m) | attributes_to_add  # add to the set
      end
    end
    
    logger.debug("Present content of accessible attributes: #{ self._accessible_attributes.inspect }")
  end
  
  def self.accessible_attributes(role = :default, mode = :read)
    accessible_attributes_configs[role][mode]    # map arguments to an access to a hash (roles) of hashes (read / write - mode)
  end
  
  
  
  private
  
    # Private method managing the access to the attributes hash of hashes. 
    # Automatically constructs a new hash, if there hasn't been any.
    def self.accessible_attributes_configs
      self._accessible_attributes ||= begin      # return the hash of hashes or create it
        Hash.new do |h,k|                        # create the outer-hash (:role) with a default value that is also a hash
          h[k] = Hash.new do |ih, ik|            # crate the inner-hash (:mode) 
            ih[ik] = []                          #   with a default value that is an empty array (will hold the attributes)
          end
        end
      end
    end
  
end