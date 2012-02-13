# redirects to www.example.com if a user goes to example.com
class NoWww

  def initialize(app)
    @app = app
  end

  def call(env)

    request = Rack::Request.new(env)

    if request.host.starts_with?("www.")
      [301, {"Location" => request.url.sub("//www.", "//")}, self]
    else
      @app.call(env)
    end
  end

  def each(&block)
  end

end