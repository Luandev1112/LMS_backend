require 'rails_helper'

describe 'POST /login', type: :request do

  let(:user) { create :user }

  before { post user_session_path, params: params }

  context 'when params are correct' do

    let(:params) {
      {
        user: {
          email: user.email,
          password: user.password
        }
      }
    }

    it { expect(response).to have_http_status(200) }

    it 'has an Authorization response header' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'has "Authorization"="Bearer xxxxx"' do
      expect(response.headers['Authorization'].split(' ').first).to eq "Bearer"
    end

    it 'returns valid JWT token' do
      token_from_request = response.headers['Authorization'].split(' ').last
      decoded_token = JWT.decode(token_from_request, Rails.application.credentials.devise_jwt_secret_key, true)

      expect(decoded_token.first['sub']).to be_present
    end
  end

  context 'when login params are incorrect' do

    let(:params) {
      { user: { email: 'wrong@email.com', password: 'ha' } }
    }
    
    it 'returns unathorized status' do
      expect(response.status).to eq 401
    end
  end
end

describe 'DELETE /logout', type: :request do
  it 'returns 204, no content' do
    delete '/logout'
    expect(response).to have_http_status(204)
  end
end