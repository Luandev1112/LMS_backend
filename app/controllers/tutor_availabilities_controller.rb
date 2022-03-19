class TutorAvailabilitiesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  def index
    render json: TutorAvailabilitySerializer.new(current_user.tutor_availabilities).serialize
  end

  def create
    tutor_availability = TutorAvailability.create(tutor_availability_params)
    
    if authorize!(:create, tutor_availability) && tutor_availability.valid?
      render json: TutorAvailabilitySerializer.new(tutor_availability).serialize
    else
      render json: tutor_availability.errors.messages, status: 422
    end
  end

  def destroy
    tutor_availability = TutorAvailability.find params[:id]
    tutor_availability.destroy if authorize! :destroy, tutor_availability
    render json: TutorAvailabilitySerializer.new(tutor_availability).serialize
  end

  private

  def tutor_availability_params
    params.require(:tutor_availability).permit(:tutor_id, :availability_id)
  end
end