class DashboardController < ApplicationController
  
  before_filter :authenticate
  before_filter :authorize_staff
  before_filter :deny_api
  
  def show
    
    @title = "Dashboard"

    @current_identity = current_identity
    @latest_identity = Identity.order('created_at DESC').first
    
    @user_stats = {
      total_accounts:      Identity.count,
      validated_accounts:  Identity.where('activated IS NOT NULL').count,
      signups_last_hour:   Identity.where(['created_at > ?', Time.now - 1.hours]).count,
      signups_last_day:    Identity.where(['created_at > ?', Time.now - 1.days]).count,
      signups_last_week:   Identity.where(['created_at > ?', Time.now - 1.weeks]).count,
      signups_last_month:  Identity.where(['created_at > ?', Time.now - 1.months]).count,
      on_waiting_lists:    Identity.joins('LEFT OUTER JOIN granted_scopes ON granted_scopes.identity_id = identities.id').where('granted_scopes.identity_id IS NULL').count,

      due_activations:     Identity.where(['activated IS NULL AND created_at < ?', Time.now - 3.days]).count,
    }

    @waiting_identities =  Identity.unscoped.joins('LEFT OUTER JOIN granted_scopes ON granted_scopes.identity_id = identities.id').where('granted_scopes.identity_id IS NULL').order('created_at ASC');

  end
  
end
