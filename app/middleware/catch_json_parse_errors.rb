# https://stackoverflow.com/questions/40268101/how-to-rescue-actiondispatchparamsparserparseerror-and-return-custom-api-err

class CatchJsonParseErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue ActionDispatch::Http::Parameters::ParseError => error
      if env['HTTP_ACCEPT'] =~ /application\/json/ || env['CONTENT_TYPE'] =~ /application\/json/
        return [
          418, 
          { "Content-Type": "application/json" },
          [{ 
            status: "I'm not a teapot you're a teapot", 
            error: "wtf malformed json, relayed error: #{error}" 
          }.to_json]
        ]
      else
        raise error
      end
    end
  end
end