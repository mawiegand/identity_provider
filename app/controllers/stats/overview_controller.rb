class Stats::OverviewController < ApplicationController
  
  before_filter :authenticate
  before_filter :authorize_staff
  before_filter :deny_api
  
  def show
    
    # user related stuff, retention and churn
    
    total_users    = Identity.count.to_f
    total_users_60 = [Identity.since_date(60.days.ago).count.to_f, 1.0].max
    
    num_users_after_month1 = Identity.where(['age_days >= 30']).count
    num_users_after_month2 = Identity.where(['age_days >= 60']).count
    num_users_after_month3 = Identity.where(['age_days >= 90']).count

    @title        = "Overview"

    @average_age  = Identity.average(:age_in_hours).to_f / 24.0
    @churn_month1 = 1.0 - num_users_after_month1 / [total_users, 1].max.to_f
    @churn_month2 = 1.0 - num_users_after_month2 / [num_users_after_month1, 1].max.to_f
    @churn_month3 = 1.0 - num_users_after_month3 / [num_users_after_month2, 1].max.to_f
    
    @retention    = [ 1.0 ]
    @churn        = []

    @retention_60 = [ 1.0 ]
    @churn_60     = []
    
    @total_net_earnings  = Stats::MoneyTransaction.total_net_earnings
    @total_chargebacks   = Stats::MoneyTransaction.total_chargebacks
    
    living_last    = total_users
    living_last_60 = total_users_60
    
    for i in 1..30
      living = Identity.where(['age_days >= ?', i]).count
      @retention << (living/total_users)
      @churn << (1-living.to_f/[living_last, 1].max)
      living_last = living

      living_60 = Identity.since_date(60.days.ago).where(['age_days >= ?', i]).count
      @retention_60 << (living_60/total_users_60)
      @churn_60 << (1-living_60.to_f/[living_last_60, 1].max)
      living_last_60 = living_60
    end
    
    
    # earnings, LV, CLV etc.
    
    @earnings     = Identity.sum(:earnings)
    @paying_users = Identity.where('earnings > 0').count
    @lv           = @earnings / [total_users, 1].max
    @clv          = @earnings / [@paying_users, 1].max
    
  end
   
end
