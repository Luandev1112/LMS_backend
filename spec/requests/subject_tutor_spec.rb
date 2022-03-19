require 'rails_helper'

describe "SubjectTutor management" do

  let(:subject) { create :subject }
  let(:tutor) { create :tutor }
  let(:subject_tutor) { create :subject_tutor, subject: subject, tutor: tutor }
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
  #     get '/language_users', headers: headers
  #   }
  # end

  describe "POST create" do
    let(:json) { {} }

    before {
      post "/subject_tutors", params: json, headers: headers
    }

    context "No-one logged in" do
      let(:headers) { {} }

      it { expect(response.status).to eq 401 }
      it { expect(response.body).to eq "You need to sign in or sign up before continuing." }
    end

    context "Admin creating a SubjectTutor on behalf of another tutor" do

      let(:admin) { true }
      let(:json) { 
        { 
          subject_tutor: {
            subject_id: subject.id,
            tutor_id: create(:tutor).id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'subject_tutors' }
    end

    context "Non-admin creating a SubjectTutor on behalf of another saver" do

      let(:json) { 
        { 
          subject_tutor: {
            subject_id: subject.id,
            tutor_id: create(:tutor).id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 403 }
      it { expect(response.body).to eq 'You are not authorized to access this page.' }
    end

    context "Owner of this to-be-created SubjectTutor logged in" do

      let(:json) { 
        { 
          subject_tutor: {
            subject_id: subject.id,
            tutor_id: tutor.id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'subject_tutors' }
    end

    context "Owner of this SubjectTutor logged in *and* blacklisted" do
      let(:blacklist) { true }

      it { expect(response.status).to eq 401 }
      it { expect(response_json['error']).to eq 'revoked token' }
    end
  end

  describe "DELETE destroy" do

    let(:id) { subject_tutor.id }

    before {
      delete "/subject_tutors/#{ id }", headers: headers
    }

    context "Admin logged in" do
      let(:admin) { true }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'subject_tutors' }
    end

    context "Owner logged in" do
      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'subject_tutors' }
    end

    context "Non-owner logged in" do
      let(:another_subject_tutor) {
        create :subject_tutor, subject: create(:subject), tutor: create(:tutor) 
      }
      let(:id) { another_subject_tutor.id }

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