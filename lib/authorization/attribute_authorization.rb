
# The AttributeAuthorizationController's design goal is to provide a mechanism
# for role-based authorizing access to indiviual attributes of the controlled
# resource, where the mechanism closely resembles the interface of the 
# mass-assignment access control in ActiveModel.
module FiveDAuthorization
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
        
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
    def attr_readable(*args)
      options = args.extract_options!
      role = options[:as]   || :default
        
      logger.debug(options.inspect)
      logger.debug(args.inspect)
    
      attributes_to_add = args.map { |attr| attr.to_s }  # make strings from symbols
    
      @_five_d_readable_attributes = readable_attributes_configs.dup  # why duplicate and re-assign? because someone else may hold the original array (e.g. in case part of it is used in this very call to attr_access)
    
      Array.wrap(role).each do | r |
        @_five_d_readable_attributes[r] = readable_attributes(r) | attributes_to_add  # add to the set
      end
    
      logger.debug("Present content of readable attributes: #{ @_five_d_readable_attributes.inspect }")
    end
  
    def readable_attributes(role = :default)
      readable_attributes_configs[role]            # map arguments to an access to a hash of roles
    end
  
  
    private
  
      # Private method managing the access to the attributes hash of hashes. 
      # Automatically constructs a new hash, if there hasn't been any.
      def readable_attributes_configs
        @_five_d_readable_attributes ||= begin     # return the hash of hashes or create it
          Hash.new do |h,k|                        # create the outer-hash (:role)
            h[k] =  []                             #   with a default value that is an empty array (will hold the attributes)
          end
        end
      end
  end
  
end

# include the module into ActiveRecord::Base
ActiveRecord::Base.send :include, FiveDAuthorization