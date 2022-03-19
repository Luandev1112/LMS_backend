require 'rails_helper'

describe "LanguageUser management" do

  let(:user) { create :user }
  let(:language) { create :language }
  let(:language_user) { create :language_user, language: language, user: user }
  let(:blacklist) { false }
  let(:admin) { false }
  let(:headers) { jwt_headers_for user }

  before { 
    blacklist_user(user, headers) if blacklist
    user.add_role(:admin) if admin 
  }

  # TBD - so far we've got a GET /language_users returning all for current_user,
  # but we might change that later
  # describe "GET index" do

  #   before {
  #     get '/language_users', headers: headers
  #   }
  # end

  describe "POST create" do
    let(:json) { {} }

    before {
      post "/language_users", params: json, headers: headers
    }

    context "No-one logged in" do
      let(:headers) { {} }

      it { expect(response.status).to eq 401 }
      it { expect(response.body).to eq "You need to sign in or sign up before continuing." }
    end

    context "Admin creating a LanguageUser on behalf of another user" do

      let(:admin) { true }
      let(:json) { 
        { 
          language_user: {
            language_id: language.id,
            user_id: create(:user).id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'language_users' }
    end

    context "Non-admin creating a LanguageUser on behalf of another user" do

      let(:json) { 
        { 
          language_user: {
            language_id: language.id,
            user_id: create(:user).id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 403 }
      it { expect(response.body).to eq 'You are not authorized to access this page.' }
    end

    context "Owner of this to-be-created LanguageUser logged in" do

      let(:json) { 
        { 
          language_user: {
            language_id: language.id,
            user_id: user.id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'language_users' }
    end

    context "Owner of this LanguageUser logged in *and* blacklisted" do
      let(:blacklist) { true }

      it { expect(response.status).to eq 401 }
      it { expect(response_json['error']).to eq 'revoked token' }
    end
  end

  describe "DELETE destroy" do

    let(:id) { language_user.id }

    before {
      delete "/language_users/#{ id }", headers: headers
    }

    context "Admin logged in" do
      let(:admin) { true }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'language_users' }
    end

    context "Owner logged in" do
      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'language_users' }
    end

    context "Non-owner logged in" do

      let(:id) { create(:language_user).id }

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