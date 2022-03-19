class SessionsController < Devise::SessionsController

  def create
    super do
      @token = current_token
    end
  end

  def show
  end

  private
  
  def current_token
    request.env['warden-jwt_auth.token']
  end

  def respond_to_on_destroy
    head :no_content
  end
end