# The LogEntriesController provides an interface to browse
# and filter entries of type LogEntry. Presently, it provides
# a paginated index as its only action that comes with a form
# to filter the entries for specific values in their attributes.
# Input to the form fields is sanitized before being send to 
# the database, but it's possible to use SQL's special '%' 
# character to look for partial matches in strings.
class LogEntriesController < ApplicationController
  
  before_filter :authenticate
  before_filter :authorize_staff

  # Returns a view containing a paginated index of all 
  # LogEntries. Allows to filter for specific values
  # in attributes.
  def index
    @title = "Log"
    
    where_string = "?=?";
    where_parameters = [ true, true ];
    
    if !params[:description].nil? && params[:description] != ""
      where_string += " AND description LIKE ?"
      where_parameters  << params[:description] 
    end

    if !params[:event_type].nil? && params[:event_type] != ""
      where_string += " AND event_type LIKE ?"
      where_parameters  << params[:event_type] 
    end

    if !params[:ip].nil? && params[:ip] != ""
      where_string += " AND ip LIKE ?"
      where_parameters  << params[:ip] 
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
    
    @log_entries = LogEntry.paginate(:page => params[:page], :per_page => 20).where(where_string, *where_parameters)
  end

end
