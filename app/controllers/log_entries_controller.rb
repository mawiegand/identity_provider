class LogEntriesController < ApplicationController
  
  before_filter :authenticate, :only => [:index]

  def index
    @title = "Log"
    @log_entries = LogEntry.paginate(:page => params[:page], :per_page => 100).order('created_at DESC')
  end

  private

    def authenticate 
      deny_access unless signed_in?
    end
end
