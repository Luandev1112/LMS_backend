require 'rails_helper'

describe "LanguageUser management" do

  let(:student) { create :student }
  let(:subject) { create :subject }
  let(:student_subject) { create :student_subject, student: student, subject: subject }
  let(:blacklist) { false }
  let(:admin) { false }
  let(:headers) { jwt_headers_for student }

  before { 
    blacklist_user(student, headers) if blacklist
    student.add_role(:admin) if admin 
  }

  # TBD - so far we've got a GET /student_subjects returning all for current_user,
  # but we might change that later
  # describe "GET index" do

  #   before {
  #     get '/language_users', headers: headers
  #   }
  # end

  describe "POST create" do
    let(:json) { {}.to_json }

    before {
      post "/student_subjects", params: json, headers: headers
    }

    context "No-one logged in" do
      let(:headers) { {} }

      it { expect(response.status).to eq 401 }
      it { expect(response.body).to eq "You need to sign in or sign up before continuing." }
    end

    context "Admin creating a StudentSubject on behalf of another student" do

      let(:admin) { true }
      let(:json) { 
        { 
          student_subject: {
            student_id: create(:student).id,
            subject_id: subject.id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'student_subjects' }
    end

    context "Non-admin creating a StudentSubject on behalf of another student" do

      let(:json) { 
        { 
          student_subject: {
            student_id: create(:student).id,
            subject_id: subject.id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 403 }
      it { expect(response.body).to eq 'You are not authorized to access this page.' }
    end

    context "Owner of this to-be-created StudentSubject logged in" do

      let(:json) { 
        { 
          student_subject: {
            student_id: student.id,
            subject_id: subject.id,
          }
        }.to_json
      }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'student_subjects' }
    end

    context "Owner of this StudentSubject logged in *and* blacklisted" do
      let(:blacklist) { true }

      it { expect(response.status).to eq 401 }
      it { expect(response_json['error']).to eq 'revoked token' }
    end
  end

  describe "DELETE destroy" do

    let(:id) { student_subject.id }

    before {
      delete "/student_subjects/#{ id }", headers: headers
    }

    context "Admin logged in" do
      let(:admin) { true }

      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'student_subjects' }
    end

    context "Owner logged in" do
      it { expect(response.status).to eq 200 }
      it { expect(response_json['data']['type']).to eq 'student_subjects' }
    end

    context "Non-owner logged in" do

      let(:id) { create(:student_subject).id }

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