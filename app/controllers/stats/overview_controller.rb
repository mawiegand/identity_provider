class Stats::OverviewController < ApplicationController
  
  before_filter :authenticate
  before_filter :authorize_staff
  before_filter :deny_api
  
  def show
    total_users   = Identity.count.to_f
    num_users_after_month1 = Identity.where(['age_days >= 30']).count
    num_users_after_month2 = Identity.where(['age_days >= 60']).count
    num_users_after_month3 = Identity.where(['age_days >= 90']).count

    @title        = "Overview"

    @average_age  = Identity.average(:age_in_hours).to_f / 24.0
    @churn_month1 = 1.0 - num_users_after_month1 / [total_users, 1].max.to_f
    @churn_month2 = 1.0 - num_users_after_month2 / [num_users_after_month1, 1].max.to_f
    @churn_month3 = 1.0 - num_users_after_month3 / [num_users_after_month2, 1].max.to_f
    
    @retention    = [ 1.0 ]
    
    @total_net_earnings  = Stats::MoneyTransaction.total_net_earnings
    @total_chargebacks   = Stats::MoneyTransaction.total_chargebacks
    
    for i in 1..30
      living = Identity.where(['age_days >= ?', i]).count
      @retention << (living/total_users)
    end
  end
   
end
