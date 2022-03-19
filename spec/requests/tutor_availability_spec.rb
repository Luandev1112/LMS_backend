require 'rails_helper'

describe "TutorAvailability management" do

  let(:tutor) { create :tutor }
  let(:availability) { create :availability }
  let(:tutor_availability) { create :tutor_availability, tutor: tutor, availability: availability }
  let(:blacklist) { false }
  let(:admin) { false }
  let(:headers) { jwt_headers_for tutor }

  before { 
    blacklist_user(tutor, headers) if blacklist
    tutor.add_role(:admin) if admin 
  }

  # TBD - so far we've got a GET /student_subjects returning all for current_user,
  # but we might change that later
  # describe "GET index" do

  #   before {
  #     get '/tutor_availabilities', headers: headers
  #   }
  # end

  describe "POST create" do
    let(:json) { {}.to_json }

    before {
      post "/tutor_availabilities", params: json, headers: headers
    }

    context "No-one logged in" do
      let(:headers) { {} }

      it { expect(response.status).to eq 401 }
      it { expect(response.body).to eq "You need to sign in or sign up before continuing." }
    end

    context "Admin creating a TutorAvailability on behalf of another tutor" do

      let(:admin) { true }
      let(:json) { 
        { 
          tutor_availability: {
            tutor_id: create(:tutor).id,
            availability_id: availability.id
          }
        }.to_json
      }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'tutor_availabilities' }
    end

    context "Non-admin creating a TutorAvailability on behalf of another tutor" do

      let(:json) { 
        { 
          tutor_availability: {
            tutor_id: create(:tutor).id,
            availability_id: availability.id
          }
        }.to_json
      }

      it { expect(response.status).to eq 403 }
      it { expect(response.body).to eq 'You are not authorized to access this page.' }
    end

    context "Owner of this to-be-created TutorAvailability logged in" do

      let(:json) { 
        { 
          tutor_availability: {
            tutor_id: tutor.id,
            availability_id: availability.id
          }
        }.to_json
      }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'tutor_availabilities' }
    end

    context "Owner of this TutorAvailability logged in *and* blacklisted" do
      let(:blacklist) { true }

      it { expect(response.status).to eq 401 }
      it { expect(response_json['error']).to eq 'revoked token' }
    end
  end

  describe "DELETE destroy" do

    let(:id) { tutor_availability.id }

    before {
      delete "/tutor_availabilities/#{ id }", headers: headers
    }

    context "Admin logged in" do
      let(:admin) { true }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'tutor_availabilities' }
    end

    context "Owner logged in" do
      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'tutor_availabilities' }
    end

    context "Non-owner logged in" do

      let(:id) { create(:tutor_availability).id }

      it { expect(response.status).to eq 403 }
      it { expect(response.body).to eq 'You are not authorized to access this page.' }
    end

    context "No-one logged in" do
      let(:headers) { {} }

      it { expect(response.status).to eq 401 }
      it { expect(response.body).to eq "You need to sign in or sign up before continuing." }
    end

    context "Blacklisted owner logged in" do
      let(:blacklist) { true }

      it { expect(response.status).to eq 401 }
      it { expect(response_json['error']).to eq 'revoked token' }
    end
  end

end