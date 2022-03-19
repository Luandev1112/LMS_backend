class StudentSubjectsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  def index
    render json: StudentSubjectSerializer.new(current_user.student_subjects).serialize
  end

  def create
    student_subject = StudentSubject.create(student_subject_params)
    
    if authorize!(:create, student_subject) && student_subject.valid?
      render json: StudentSubjectSerializer.new(student_subject).serialize
    else
      render json: student_subject.errors.messages, status: 422
    end
  end

  def destroy
    student_subject = StudentSubject.find params[:id]
    student_subject.destroy if authorize! :destroy, student_subject
    render json: StudentSubjectSerializer.new(student_subject).serialize
  end

  private

  def student_subject_params
    params.require(:student_subject).permit(:student_id, :subject_id)
  end
end