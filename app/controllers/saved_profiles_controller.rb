class SavedProfilesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  def index
    render json: SavedProfileSerializer.new(current_user.saved_profiles).serialize
  end

  def create
    saved_profile = SavedProfile.create(saved_profile_params)
    
    if authorize!(:create, saved_profile) && saved_profile.valid?
      render json: SavedProfileSerializer.new(saved_profile).serialize
    else
      render json: saved_profile.errors.messages, status: 422
    end
  end

  def destroy
    saved_profile = SavedProfile.find params[:id]
    saved_profile.destroy if authorize! :destroy, saved_profile
    render json: SavedProfileSerializer.new(saved_profile).serialize
  end

  private

  def saved_profile_params
    params.require(:saved_profile).permit(:saver_id, :savee_id)
  end
end