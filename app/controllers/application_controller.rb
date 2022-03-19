class ApplicationController < ActionController::API
  
  respond_to :json

  rescue_from CanCan::AccessDenied do |e|
    render json: e.message, status: 403
  end
end
