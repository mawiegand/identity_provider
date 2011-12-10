class LogEntriesController < ApplicationController
  
  before_filter :authenticate, :only => [:index]

  def index
    @title = "Log"
    
    where_string = "1";
    where_parameters = [];
    
    if !params[:description].nil? && params[:description] != ""
      where_string += " AND description LIKE ?"
      where_parameters  << params[:description] 
    end

    if !params[:event_type].nil? && params[:event_type] != ""
      where_string += " AND event_type LIKE ?"
      where_parameters  << params[:event_type] 
    end
    
    if !params[:affected_table].nil? && params[:affected_table] != ""
      where_string += " AND affected_table LIKE ?"
      where_parameters  << params[:affected_table] 
    end
    
    if !params[:affected_id].nil? && params[:affected_id] != ""
      where_string += " AND affected_id == ?"
      where_parameters  << params[:affected_id] 
    end
    
    if !params[:identity_id].nil? && params[:identity_id] != ""
      where_string += " AND identity_id == ?"
      where_parameters  << params[:identity_id] 
    end
    
    @log_entries = LogEntry.paginate(:page => params[:page], :per_page => 20).where(where_string, *where_parameters).order('created_at DESC')
  end

  private

    def authenticate 
      deny_access unless signed_in?
    end
end
