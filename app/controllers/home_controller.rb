class HomeController < ApplicationController

  # GET /
  # Just a placeholder. Returns the first page of all Tutors.
  def index
    render json: TutorSerializer.new(Tutor.all).serialize
  end
end