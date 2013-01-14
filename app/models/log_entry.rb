# Log entries store information about changes made to the 
# database. For each change made by a controller, that 
# controller should create a LogEntry explaining that
# particular change. Besides a human readable description,
# a log entry has information about the identity that
# made the change, the identity's role (none, user, staff,
# or admin) and the table and table-row affected by the
# change. 
#
# Attributes are read only so the log can not be manipulated
# through the rails application.
#
# Log entries can be easily browsed and filtered by accessing
# the LogEntriesController at /log_entries . 
#
# == Schema Information
#
# Table name: log_entries
#
#  id             :integer         not null, primary key
#  identity_id    :integer
#  role           :string(255)
#  affected_table :string(255)
#  affected_id    :integer
#  event_type     :string(255)
#  description    :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#
class LogEntry < ActiveRecord::Base
  belongs_to :identity      # entries are connected to the current_user

  attr_accessible :identity_id, :role, :affected_table, :affected_id, :event_type, :description, :ip
  attr_readonly :identity_id, :role, :affected_table, :affected_id, :event_type, :description, :ip
  
  default_scope :order => 'log_entries.created_at DESC'   # most recent entry comes first
  
    # Logging  
  def self.create_signout(identity, remote_ip = 'unknown')
    LogEntry.create(:identity_id    => identity.id,
                    :role           => identity.role_string,
                    :affected_table => 'identity',
                    :affected_id    => identity.id,
                    :event_type     => 'signout_destroy',
                    :description    => "User #{ identity.address_informal } signed out.",
                    :ip             => remote_ip);
  end
  
  def self.create_signin_failure(email, as_identity, remote_ip = 'unknown')
    identity = Identity.find_by_email(email);
    entry = LogEntry.new(:affected_table => "identity",
                         :event_type     => 'signin_failure', 
                         :ip             => remote_ip);
    if !as_identity.nil?
      entry.identity_id = as_identity.id;
      entry.role = as_identity.role_string;
    else
      entry.role = 'none'
    end
    if !identity.nil?
      entry.affected_id = identity.id
    end
    entry.description = "Sign-in with email #{email} (#{ identity.nil? || identity.nickname.nil? ? 'unknown user' : 'user ' + identity.nickname  }) did fail#{ as_identity.nil? ? '' : ' for current_user ' + (as_identity.nickname.nil? ? as_identity.email : as_identity.email) }."
    entry.save
    
    entry
  end

  def self.create_signin_success(email, identity, remote_ip = 'unknwon')
    entry = LogEntry.create(:identity_id    => identity.id,
                            :role           => identity.role_string,
                            :affected_table => 'identity',
                            :affected_id    => identity.id,
                            :event_type     => 'signin_success',
                            :description    => "Sign-in with #{email} (user #{ identity.nickname }) did succeed.",
                            :ip             => remote_ip);
                    
    entry.multi_check(1.days)
  end 
  

  def self.create_signup_attempt(params, as_identity, remote_ip = 'unknwon', user_agent = nil, referer =nil, request_url=nil)
    username = params.has_key?(:identity) ? (params[:identity][:email] || params[:identity][:nickname]) : params[:email] || 'no username'
    
    entry = LogEntry.new(:affected_table => 'identity',
                         :event_type     => 'signup_attempt',
                         :description    => ("Sign-up attempt with #{ username } using agent #{ (user_agent || 'unknown')[0..70] } refered by #{ referer || 'unknown' }, originial request #{ request_url || 'unknown' }.")[0..254],
                         :ip             => remote_ip);
    if !as_identity.nil?
      entry.identity_id = as_identity.id;
      entry.role = as_identity.role_string;
    else
      entry.role = 'none'
    end
    entry.save
    
    entry
  end

  def self.create_signup_success(params, identity, remote_ip = 'unknwon')
    username = params.has_key?(:identity) ? (params[:identity][:email] || params[:identity][:nickname]) : params[:email] || 'no username'
    
    LogEntry.create(:identity_id    => identity.id,
                    :role           => identity.role_string,
                    :affected_table => 'identity',
                    :affected_id    => identity.id,
                    :event_type     => 'signup_success',
                    :description    => "Sign-up with #{username} (user #{ identity.nickname }) did succeed.",
                    :ip             => remote_ip);
  end 

  def self.create_signup_failure(params, as_identity, remote_ip = 'unknown')
    username = params.has_key?(:identity) ? (params["identity"][:email] || params[:identity][:nickname]) : params[:email] || 'no username'
    
    entry = LogEntry.new(:affected_table => "identity",
                         :event_type     => 'signup_failure', 
                         :ip             => remote_ip);
    if !as_identity.nil?
      entry.identity_id = as_identity.id;
      entry.role = as_identity.role_string;
    else
      entry.role = 'none'
    end
    entry.description = ("Sign-up with #{ username } did fail#{ as_identity.nil? ? '' : ' for current_user ' + (as_identity.nickname.nil? ? as_identity.email : as_identity.email) }.")[0..200]
    entry.save
    
    entry
  end

  
  def self.create_auth_token_success(username, identity, client_id, remote_ip = 'unknwon')
    LogEntry.create(:identity_id    => identity.id,
                    :role           => identity.role_string,
                    :affected_table => 'identity',
                    :affected_id    => identity.id,
                    :event_type     => 'auth_token_success',
                    :description    => "Authentication with client id #{client_id} for #{username} (user #{ identity.nickname }) did succeed.",
                    :ip             => remote_ip);
  end  
  
  def self.create_auth_token_failure(username, as_identity, client_id, error_code, error_description, remote_ip = 'unknown')
    identity = Identity.find_by_email(username);
    identity = Identity.find_by_id_identifier_or_nickname(username)  if identity.nil?

    entry = LogEntry.new(:affected_table => "identity",
                         :event_type     => 'auth_token_failure', 
                         :ip             => remote_ip);
    if !as_identity.nil?
      entry.identity_id = as_identity.id;
      entry.role = as_identity.role_string;
    else
      entry.role = 'none'
    end
    if !identity.nil?
      entry.affected_id = identity.id
    end
    entry.description = ("Authentication with client id #{client_id} for #{username} (#{ identity.nil? || identity.nickname.nil? ? 'unknown user' : 'user ' + identity.nickname  }) did fail#{ as_identity.nil? ? '' : ' for current_user ' + (as_identity.nickname.nil? ? as_identity.email : as_identity.email) }. Error #{ error_code }: #{error_description}")[0..200]
    entry.save
    
    entry
  end  
  
  def multi_check(time_span)
    multiple_entries = LogEntry.where(['created_at > ? AND event_type = "signup_success" AND ip = ? AND identity_id <> ?', self.created_at - time_span, self.ip, self.identity_id])

    return    if multiple_entries.count == 0
    
    identity_ids = multiple_entries.map do |entry|
      entry.identity_id
    end
    
    description "Same ip logged in with users #{ identity_ids.join(', ') }."

    LogEntry.create(:identity_id    => self.identity.id,
                    :role           => self.identity.role_string,
                    :affected_table => 'identity',
                    :affected_id    => identity.id,
                    :event_type     => 'multi_detection_triggered',
                    :description    => (description)[0..250],
                    :ip             => self.remote_ip);

  end
  
end


