class DashboardController < ApplicationController
  
  before_filter :authenticate
  before_filter :authorize_staff
  before_filter :deny_api
  
  def show
    
    @title = "Dashboard"

    @current_identity = current_identity
    @latest_identity = Identity.unscoped.order('created_at DESC').first
    
    @user_stats = {
      total_accounts:      Identity.count,
      validated_accounts:  Identity.where('activated IS NOT NULL').count,
      signups_last_hour:   Identity.where(['created_at > ?', Time.now - 1.hours]).count,
      signups_last_day:    Identity.where(['created_at > ?', Time.now - 1.days]).count,
      signups_last_week:   Identity.where(['created_at > ?', Time.now - 1.weeks]).count,
      signups_last_month:  Identity.where(['created_at > ?', Time.now - 1.months]).count,
      on_waiting_lists:    Identity.joins('LEFT OUTER JOIN granted_scopes ON granted_scopes.identity_id = identities.id').where(['granted_scopes.identity_id IS NULL AND identities.deleted = ?', false]).count,

      due_activations:     Identity.where(['activated IS NULL AND created_at < ?', Time.now - 3.days]).count,
    }
    
    # TODO: this is a wack-a-doo hack. need to generalize it to all clients in the system
    @wackadoo_client = Client.find_by_identifier('WACKADOOHTML5')
    
    @wackadoo_grant = {
      client_id: @wackadoo_client.id,
      scopes:    @wackadoo_client.scopes,
    }

    @waiting_identities =  Identity.unscoped.joins('LEFT OUTER JOIN granted_scopes ON granted_scopes.identity_id = identities.id').where(['granted_scopes.identity_id IS NULL AND identities.deleted = ?', false]).order('created_at ASC');

  end
  
  def create 
    
    if params.has_key?('grant')       # GRANTING ACCESS TO IDENTITIES
      grant = params[:grant]
      
      identity = Identity.find_by_id(grant[:identity_id])
      redirect_to dashboard_path,   :notice => "Identity not found."     if identity.nil?

      if !identity.grants.create({client_id: grant[:client_id], scopes: grant[:scopes],}) 
        logger.error "Could not grant #{ grant.inspect } to #{ identity.inspect}."
        redirect_to dashboard_path, :notice => "Failed to grant access to #{ identity.email }."    
      else
        logger.info "Send email about granted access to #{ identity.email }."
        send_manually_granted_access_email(identity)      # send email notification
        redirect_to dashboard_path, :notice => "Granted #{ identity.email } access to Wack-a-Doo. Email sent."      
      end
    else                              # UNKOWN DASHBOARD ACTION
      redirect_to dashboard_path,   :notice => "Unknown action."
    end
  end
  
  protected
  
    # this method sends the email in the locale of the recipient
    def send_manually_granted_access_email(identity)
      old_locale = I18n.locale
      I18n.locale = identity.locale unless identity.locale.blank?
      IdentityMailer.manually_granted_access_email(identity).deliver      # send email notification
    ensure
      I18n.locale = old_locale  
    end
  
end
