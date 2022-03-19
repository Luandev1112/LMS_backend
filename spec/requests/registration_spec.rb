require 'rails_helper'

describe 'POST /signup', type: :request do
  
  let(:tutor_attrs) { attributes_for :tutor }
  let(:postcode) { create :postcode }
  let(:profile_image_datastring) {
    image = File.open(Rails.root.join('spec', 'support', 'assets', 'austin-powers-headshot.jpeg'), 'rb').read

    "data:image/jpeg;base64,#{Base64.encode64(image)}"
  }

  let(:params) { 
    { 
      user: {
        # User attrs
        email: tutor_attrs[:email],
        password: tutor_attrs[:password],
        password_confirmation: tutor_attrs[:password],
        first_name: tutor_attrs[:first_name],
        last_name: tutor_attrs[:last_name],
        last_seen: tutor_attrs[:last_seen],
        sex: tutor_attrs[:sex],
        age: tutor_attrs[:age],
        profile_image: profile_image_datastring,

        # Tutor attrs
        biography: tutor_attrs[:biography],
        hourly_rate: tutor_attrs[:hourly_rate],
        max_distance_available: tutor_attrs[:max_distance_available],

        city: tutor_attrs[:city],

        postcode: postcode.code,

        subject: tutor_attrs[:subject]
      }
    }
  }

  context "correct params" do

    describe "just regular user attributes" do

      before { post '/signup', params: params }

      it { expect(response).to have_http_status(200) }

      it "saves and returns the email" do
        expect(response_json['data']['attributes']['email'])
          .to eq tutor_attrs[:email]
      end

      it "saves and returns the first name" do
        expect(response_json['data']['attributes']['first_name'])
          .to eq tutor_attrs[:first_name]
      end

      it "saves and returns the last name" do
        expect(response_json['data']['attributes']['last_name'])
          .to eq tutor_attrs[:last_name]
      end

      it "saves and returns last_seen (sidestep format issues by comparing both timestamps)" do
        expect(Time.parse(response_json['data']['attributes']['last_seen']).to_i)
          .to eq tutor_attrs[:last_seen].to_i
      end

      it "saves and returns the sex" do
        expect(response_json['data']['attributes']['sex'])
          .to eq tutor_attrs[:sex]
      end

      it "saves and returns the age" do
        expect(response_json['data']['attributes']['age'])
          .to eq tutor_attrs[:age]
      end
    end

    describe "just regular user relationships" do

      before { post '/signup', params: params }

      it "saves and returns the postcode ID" do
        expect(response_json['data']['relationships']['postcode']['data']['id'])
          .to eq postcode.id.to_s
      end
    end

    describe "Different user types" do

      context "not setting any type value of any kind" do

        before { post '/signup', params: params }

        it { expect(response).to have_http_status(200) }

        it "saves and returns a regular ol' User type" do
          
          expect(response_json['data']['type']).to eq 'users'
        end
      end

      context "setting type=Tutor" do

        before do
          params[:user][:type] = 'Tutor'
          post '/signup', params: params
        end

        it { expect(response).to have_http_status(200) }

        it "saves and returns a Tutor type" do
          expect(response_json['data']['type']).to eq 'tutors'
        end

        it "saves and returns the hourly_rate" do
          expect(response_json['data']['attributes']['hourly_rate'].to_f).to eq tutor_attrs[:hourly_rate]
        end

        it "saves and returns the max_distance_available" do
          expect(response_json['data']['attributes']['max_distance_available'].to_f).to eq tutor_attrs[:max_distance_available]
        end

        it "saves and returns the biography" do
          expect(response_json['data']['attributes']['biography']).to eq tutor_attrs[:biography]
        end
      end

      context "setting type=Student" do

        before do
          params[:user][:type] = 'Student'
          post '/signup', params: params
        end

        it { expect(response).to have_http_status(200) }

        it "saves and returns a Student type" do
          expect(response_json['data']['type']).to eq 'students'
        end
      end
    end
  end

  context "incorrect params" do

    describe "password is too short" do

      before do
        params[:user][:password] = 'f'
        params[:user][:password_confirmation] = 'f'
        post '/signup', params: params
      end

      it { expect(response).to have_http_status(400) }

      it "responds with an error saying the password is too short" do 
        expect(response_json['errors'][0]['detail'])
          .to eq({ 'password' => ["is too short (minimum is 6 characters)"] })
      end
    end

    describe "password_confirmation is missing" do

      before do
        params[:user].delete :password_confirmation 
        post '/signup', params: params
      end

      it { expect(response).to have_http_status(400) }

      it "responds with an error saying that password_confirmation can't be blank" do
        expect(response_json['errors'][0]['detail'])
          .to eq({ 'password_confirmation' => ["can't be blank"] })
      end
    end

    describe "password_confirmation doesn't match password" do

      before do 
        params[:user][:password_confirmation] = 'blargh'
        post '/signup', params: params
      end

      it { expect(response).to have_http_status(400) }

      it "responds with an error saying that password_confirmation doesn't match password" do
        expect(response_json['errors'][0]['detail'])
          .to eq({ 'password_confirmation' => ["doesn't match Password"]})
      end
    end
  end

  it "increments the uploaded-file count" do
    f = fixture_file_upload(Rails.root.join('spec', 'support', 'assets', 'austin-powers-headshot.jpeg'), 'image/jpeg')

    expect {
      post '/signup', params: params
    }.to change(ActiveStorage::Attachment, :count).by(1)
  end
end