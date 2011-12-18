class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper   # session helpers must be available to all controllers
end
