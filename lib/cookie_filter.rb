class CookieFilter
  def initialize(app)
    @app = app
  end

  # this is a hook that calls the main app and then could 
  # process the app's response before returning it. this
  # hook should be used to filter the set-cookie headers.
  def call(env)
    status, headers, response = @app.call(env)
    [status, headers, response]
  end
end
