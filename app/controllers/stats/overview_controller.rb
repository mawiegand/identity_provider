class Stats::OverviewController < ApplicationController
  
  before_filter :authenticate
  before_filter :authorize_staff
  before_filter :deny_api
  
  def show
    total_users  = Identity.count.to_f

    @title = "Overview"

    @average_age = Identity.average(:age_in_hours).to_f / 24.0

    @retention   = [ 1.0 ]
    
    for i in 1..60
      living = Identity.where(['age_days >= ?', i]).count
      @retention << (living/total_users)
    end
    
  end
   
end
