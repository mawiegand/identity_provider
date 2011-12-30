require 'test_helper'

class LibAuthorizationTest < ActiveSupport::TestCase
  fixtures :all

  test "can set read access for different roles" do
    assert Identity.readable_attributes(:user).include?  'nickname'
    assert Identity.readable_attributes(:staff).include? 'surname'
  end

  test "no unauthorized readers" do
    assert !Identity.readable_attributes(:user).include?('surname')
    assert !Identity.readable_attributes(:default).include?('surname')
    assert !Identity.readable_attributes(:unknown).include?('nickname')
  end
  
  test "sanitation removes lets just pass the allowed fields" do
    identity = Identity.create({:nickname =>"minimal", 
                                :email    =>"minimal@haus.de", 
                                :password =>"minimal", 
                                :password_confirmation=>"minimal"}, :without_protection => true)
    identity = Identity.find_by_nickname('minimal')
    
    assert_not_nil identity, 'precondition does fail: no identity'
    assert identity.valid?,  'precondition does fail: identity not valid'
    
    symbol_hash = { :nickname => 'public', :email => 'not_public_for_some', :encrypted_password => 'not_public', :unknown => 'not_known' }
    string_hash = { 'nickname' => 'public', 'email' => 'not_public_for_some', 'encrypted_password' => 'not_public', 'unknown' => 'not_known' }
        
    assert (Identity.sanitized_hash_from_hash(symbol_hash, :default).keys - [ :nickname ]).empty?,  'not-readable attribute leaks through in symbol hash for :default'
    assert ([ :nickname ] - Identity.sanitized_hash_from_hash(symbol_hash, :default).keys).empty?,  'readable attribute is removed from symbol hash for :default'
    assert (Identity.sanitized_hash_from_hash(symbol_hash, :admin).keys - [ :nickname, :email ]).empty?,  'not-readable attribute leaks through in symbol hash for :admin'
    assert ([ :nickname, :email ] - Identity.sanitized_hash_from_hash(symbol_hash, :admin).keys).empty?,  'readable attribute is removed from symbol hash for :admin'
    
    assert (Identity.sanitized_hash_from_hash(string_hash, :default).keys - [ :nickname ]).empty?,  'not-readable attribute leaks through in string hash for :default'
    assert ([ :nickname ] - Identity.sanitized_hash_from_hash(string_hash, :default).keys).empty?,  'readable attribute is removed from string hash for :default'
    assert (Identity.sanitized_hash_from_hash(string_hash, :admin).keys - [ :nickname, :email ]).empty?,  'not-readable attribute leaks through in string hash for :admin'
    assert ([ :nickname, :email ] - Identity.sanitized_hash_from_hash(string_hash, :admin).keys).empty?,  'readable attribute is removed from string hash for :admin'

    assert Identity.sanitized_hash_from_model(identity, :default).keys.include?(:nickname),  'readable attribute is removed from model for :default'
    assert !Identity.sanitized_hash_from_model(identity, :default).keys.include?(:email),    'not-readable attribute leaks through in model for :default'
    assert Identity.sanitized_hash_from_model(identity, :admin).keys.include?(:email),       'readable attribute is removed from model for :admin'
    assert !Identity.sanitized_hash_from_model(identity, :admin).keys.include?(:encrypted_password),  'not-readable attribute leaks through in model for :admin'

    assert identity.sanitized_hash(:default).keys.include?(:nickname),  'readable attribute is removed by instance method for :default'
    assert !identity.sanitized_hash(:default).keys.include?(:email),    'not-readable attribute leaks through in instance method for :default'
    assert Identity.sanitized_hash_from_model(identity, :admin).keys.include?(:email),       'readable attribute is removed by instance method for :admin'
    assert !Identity.sanitized_hash_from_model(identity, :admin).keys.include?(:encrypted_password),  'not-readable attribute leaks through in instance method for :admin'
  end

end