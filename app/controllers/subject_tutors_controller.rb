class SubjectTutorsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  def index
    render json: SubjectTutorSerializer.new(current_user.subject_tutors).serialize
  end

  def create
    subject_tutor = SubjectTutor.create(subject_tutor_params)
    
    if authorize!(:create, subject_tutor) && subject_tutor.valid?
      render json: SubjectTutorSerializer.new(subject_tutor).serialize
    else
      render json: subject_tutor.errors.messages, status: 422
    end
  end

  def destroy
    subject_tutor = SubjectTutor.find params[:id]
    subject_tutor.destroy if authorize! :destroy, subject_tutor
    render json: SubjectTutorSerializer.new(subject_tutor).serialize
  end

  private

  def subject_tutor_params
    params.require(:subject_tutor).permit(:subject_id, :tutor_id)
  end
end