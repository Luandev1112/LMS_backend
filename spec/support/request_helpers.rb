require 'devise/jwt/test_helpers'

module Requests
  module JsonHelpers
    def response_json
      JSON.parse(response.body)
    end
  end

  # All kinds of goodies going on here. Here's the doc for revoke_jwt:
  # https://github.com/waiting-for-dev/devise-jwt/blob/master/lib/devise/jwt/revocation_strategies/blacklist.rb
  module JwtHelpers
    def blacklist_user(user, headers)
      jwt_token = headers['Authorization'].split(' ').last
      token_payload = jwt_token.split('.')[1]
      base64_decoded = Base64.decode64 token_payload
      json_parsed = JSON.parse(base64_decoded)
      JWTBlacklist.revoke_jwt json_parsed, user
    end

    # Remember a JWT structure: header.payload.signature.
    # Each time you call .auth_headers, the signature changes, so only
    # call jwt_headers_for once per request.
    def jwt_headers_for(user)
      json_headers = { 
        'Content-Type': 'application/json', 
        'Accept': 'application/json' 
      }
      Devise::JWT::TestHelpers.auth_headers(json_headers, user)  
    end
  end
end