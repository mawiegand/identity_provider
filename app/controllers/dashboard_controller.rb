class DashboardController < ApplicationController
  
  before_filter :authenticate
  before_filter :authorize_staff
  before_filter :deny_api
  
  def show
    
    @title = "Dashboard"

    @current_identity = current_identity
    @latest_identity = Identity.unscoped.order('created_at DESC').first
        
    @waiting_lists = []
    Client.find(:all).each do |client|
      @waiting_lists.push({
        client:  client,
        entries: Resource::WaitingList.where(client_id: client.id).order('created_at ASC')
      })
    end
    
    @user_stats = {
      total_accounts:      Identity.count,
      validated_accounts:  Identity.where('activated IS NOT NULL').count,
      signups_last_hour:   Identity.where(['created_at > ?', Time.now - 1.hours]).count,
      signups_last_day:    Identity.where(['created_at > ?', Time.now - 1.days]).count,
      signups_last_week:   Identity.where(['created_at > ?', Time.now - 1.weeks]).count,
      signups_last_month:  Identity.where(['created_at > ?', Time.now - 1.months]).count,
      on_waiting_lists:    Resource::WaitingList.count,

      due_activations:     Identity.where(['activated IS NULL AND created_at < ?', Time.now - 3.days]).count,
    }
    
    # TODO: this is a wack-a-doo hack. need to generalize it to all clients in the system
    @wackadoo_client = Client.find_by_identifier('WACKADOOHTML5')
    
    @wackadoo_grant = {
      client_id: @wackadoo_client.id,
      scopes:    @wackadoo_client.scopes,
    }
  end
  
  def create 
    
    if params.has_key?('grant')       # GRANTING ACCESS TO IDENTITIES
      grant = params[:grant]
      
      entry = Resource::WaitingList.find_by_id(grant[:entry_id])

      redirect_to dashboard_path,   :notice => "Waiting list entry not found."     if entry.nil?

      if !entry.client.grant_scopes_to_identity(entry.identity, entry.invitation, false) 
        logger.error "Could not grant scopes of client #{ entry.client.inspect } to #{ entry.identity.inspect}."
        redirect_to dashboard_path, :notice => "Failed to grant access to #{ entry.identity.email }."    
      else
        logger.info "Send email about granted access to #{ entry.identity.email }."
        send_manually_granted_access_email(entry.identity, entry.client)      # send email notification
        redirect_to dashboard_path, :notice => "Granted #{ entry.identity.email } access to #{ entry.client.identifier }. Email sent."      
      end
    else                              # UNKOWN DASHBOARD ACTION
      redirect_to dashboard_path,   :notice => "Unknown action."
    end
  end
  
  protected
  
    # this method sends the email in the locale of the recipient
    def send_manually_granted_access_email(identity, client)
      old_locale = I18n.locale
      I18n.locale = identity.locale unless identity.locale.blank?
      IdentityMailer.manually_granted_access_email(identity, client).deliver      # send email notification
    ensure
      I18n.locale = old_locale  
    end
  
end
