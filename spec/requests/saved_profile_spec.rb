require 'rails_helper'

describe "SavedProfile management" do

  let(:saver) { create :student }
  let(:savee) { create :tutor }
  let(:saved_profile) { create :saved_profile, saver: saver, savee: savee }
  let(:blacklist) { false }
  let(:admin) { false }
  let(:headers) { jwt_headers_for saver }

  before { 
    blacklist_user(saver, headers) if blacklist
    saver.add_role(:admin) if admin 
  }

  # TBD - so far we've got a GET /student_subjects returning all for current_user,
  # but we might change that later
  # describe "GET index" do

  #   before {
  #     get '/language_users', headers: headers
  #   }
  # end

  describe "POST create" do
    let(:json) { {} }

    before {
      post "/saved_profiles", params: json, headers: headers
    }

    context "No-one logged in" do
      let(:headers) { {} }

      it { expect(response.status).to eq 401 }
      it { expect(response.body).to eq "You need to sign in or sign up before continuing." }
    end

    context "Admin creating a SavedProfile on behalf of another saver" do

      let(:admin) { true }
      let(:json) { 
        { 
          saved_profile: {
            saver_id: create(:student).id,
            savee_id: savee.id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'saved_profiles' }
    end

    context "Non-admin creating a SavedProfile on behalf of another saver" do

      let(:json) { 
        { 
          saved_profile: {
            saver_id: create(:student).id,
            savee_id: savee.id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 403 }
      it { expect(response.body).to eq 'You are not authorized to access this page.' }
    end

    context "Owner of this to-be-created SavedProfile logged in" do

      let(:json) { 
        { 
          saved_profile: {
            saver_id: saver.id,
            savee_id: savee.id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'saved_profiles' }
    end

    context "Owner of this SavedProfile logged in *and* blacklisted" do
      let(:blacklist) { true }

      it { expect(response.status).to eq 401 }
      it { expect(response_json['error']).to eq 'revoked token' }
    end
  end

  describe "DELETE destroy" do

    let(:id) { saved_profile.id }

    before {
      delete "/saved_profiles/#{ id }", headers: headers
    }

    context "Admin logged in" do
      let(:admin) { true }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'saved_profiles' }
    end

    context "Owner logged in" do
      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'saved_profiles' }
    end

    context "Non-owner logged in" do

      let(:id) { create(:saved_profile).id }

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