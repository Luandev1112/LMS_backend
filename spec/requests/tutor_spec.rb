require 'rails_helper'

describe "Tutor routes" do

  let(:tutor) { create :tutor }
  let(:json) { {}.to_json }
  let(:headers) { jwt_headers_for tutor }
  let(:blacklist) { false }

  before { blacklist_user(tutor, headers) if blacklist }

  describe "POST #search" do

    before {
      post search_tutors_path, params: json, headers: headers
    }
    
    subject { response }

    context "No tutor" do
      let(:headers) { {} }

      it { is_expected.to have_http_status(401) }
      it { expect(response.body).to eq "You need to sign in or sign up before continuing." }
    end

    context "User with blacklisted jwt" do
      let(:blacklist) { true }

      it { is_expected.to have_http_status(401) }
      it { expect(response_json['error']).to eq 'revoked token' }
    end
    
    context "JSON is a bit malformed" do
      let(:json) { '{"foo":"bar}' }

      it { is_expected.to have_http_status(418) }
      it "squirts back an oh-so-hilarious taunt" do 
        expect(response_json['status']).to eq "I'm not a teapot you're a teapot" 
      end
    end

    # TODO When I submit this exact same JSON manually via Postman, it returns 500 instead of 418. Our custom middleware doesn't pick it up! Instead the web server says this:
    # 2019-11-01 13:32:37 +1300: Read error: #<TypeError: no implicit conversion of Symbol into String>
    context "JSON is malformed-er" do
      let(:json) { '{
          "rate: {},
          "availabilities": ["morninge"],
          "postcode": "234"
        }' }

      it { expect(response).to have_http_status(418) }
      it "squirts back an oh-so-hilarious taunt" do 
        expect(response_json['status']).to eq "I'm not a teapot you're a teapot" 
      end
    end

    context "all keys are absent" do
      let(:json) { '{}' }

      it { expect(response).to have_http_status(200) }
    end

    context "availabilities is an object" do
      let(:json) { '{"availabilities":{"foo":"bar"}}' }

      it { is_expected.to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/availabilities' of type object did not match the following type: array" }
    end

    context "availabilities is an array of strings" do
      let(:json) { '{"availabilities":["foo","bar"]}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/availabilities/0' of type string did not match the following type: integer" }
      it { expect(response_json['error'][1]).to include "The property '#/availabilities/1' of type string did not match the following type: integer" }
    end

    context "availabilities is an array of negative integers" do
      let(:json) { '{"availabilities":[-132,-3154,-15343,-1]}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/availabilities/0' did not have a minimum value of 0, inclusively" }
      it { expect(response_json['error'][1]).to include "The property '#/availabilities/1' did not have a minimum value of 0, inclusively" }
      it { expect(response_json['error'][2]).to include "The property '#/availabilities/2' did not have a minimum value of 0, inclusively" }
      it { expect(response_json['error'][3]).to include "The property '#/availabilities/3' did not have a minimum value of 0, inclusively" }
    end

    context "availabilities is an array of mostly positive integers, one negative" do
      let(:json) { '{"availabilities":[123,643,1,43234,-1,1231]}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/availabilities/4' did not have a minimum value of 0, inclusively" }
    end

    context "language is an array of positive integers" do 
      let(:json) { '{"availabilities":[123,643,1,43234,1,1231]}' }

      it { expect(response).to have_http_status(200) }
    end

    context "postcode is a number" do
      let(:json) { '{"postcode":2}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/postcode' of type integer did not match the following type: string" }
    end

    context "postcode is a string with non-number characters" do
      let(:json) { '{"postcode":"2343nifnle"}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/postcode' value \"2343nifnle\" did not match the regex '^[0-9]*$'" }
    end

    context "postcode is a string with non-number characters" do
      let(:json) { '{"postcode":"2343"}' }

      it { expect(response).to have_http_status(200) }
    end

    context "distance is a string" do
      let(:json) { '{"distance":"blargh"}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/distance' of type string did not match the following type: integer" }
    end

    context "distance is a negative integer" do
      let(:json) { '{"distance":-208}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/distance' did not have a minimum value of 0" }
    end

    context "distance is a positive integer" do
      let(:json) { '{"distance":208}' }

      it { expect(response).to have_http_status(200) }
    end

    context "rate is an array" do
      let(:json) { '{"rate":[1,2,3]}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/rate' of type array did not match the following type: object" }
    end

    context "rate is a string" do
      let(:json) { '{"rate":"blargh"}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/rate' of type string did not match the following type: object" }
    end

    context "rate is a negative integer" do
      let(:json) { '{"rate":-1321}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/rate' of type integer did not match the following type: object" }
    end

    context "rate is a positive integer" do
      let(:json) { '{"rate":432}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/rate' of type integer did not match the following type: object" }
    end

    context "rate is an empty object" do
      let(:json) { '{"rate":{}}' }

      it { expect(response).to have_http_status(200) }
    end

    context "rate has a key not called either 'low' or 'high'" do
      let(:json) { '{"rate":{"foo":"bar"}}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/rate' contains additional properties [\"foo\"] outside of the schema when none are allowed" }
    end

    context "rate[low] is a string" do
      let(:json) { '{"rate":{"low":"blargh"}}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/rate/low' of type string did not match the following type: number" }
    end

    context "rate[low] is a negative integer" do
      let(:json) { '{"rate":{"low":-4231}}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/rate/low' did not have a minimum value of 0, inclusively" }
    end

    context "rate[low] is a positive integer" do
      let(:json) { '{"rate":{"low":423}}' }

      it { expect(response).to have_http_status(200) }
    end

    context "rate[low] is a positive decimal" do
      let(:json) { '{"rate":{"low":423.22}}' }

      it { expect(response).to have_http_status(200) }
    end

    context "rate[high] is a string" do
      let(:json) { '{"rate":{"high":"blargh"}}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/rate/high' of type string did not match the following type: number" }
    end

    context "rate[high] is a negative integer" do
      let(:json) { '{"rate":{"high":-2342}}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/rate/high' did not have a minimum value of 0, inclusively" }
    end

    context "rate[high] is a positive integer" do
      let(:json) { '{"rate":{"high":904}}' }

      it { expect(response).to have_http_status(200) }
    end

    context "rate[high] is a positive decimal" do
      let(:json) { '{"rate":{"high":423.22}}' }

      it { expect(response).to have_http_status(200) }
    end

    context "rate[low] is greater than rate[high]" do
      let(:json) { '{"rate":{"low":34,"high":32}}' }
      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/rate/high' can't be less than '#/rate/low'" }
    end

    context "subjects is a string" do
      let(:json) { '{"subjects":"blargh"}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/subjects' of type string did not match the following type: array" }
    end

    context "subjects is an integer" do
      let(:json) { '{"subjects":5}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/subjects' of type integer did not match the following type: array" }
    end

    context "subjects is an object" do
      let(:json) { '{"subjects":{"foo":"bar"}}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/subjects' of type object did not match the following type: array" }
    end

    context "subjects is an array of strings" do
      let(:json) { '{"subjects":["foo","bar"]}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/subjects/0' of type string did not match the following type: integer" }
      it { expect(response_json['error'][1]).to include "The property '#/subjects/1' of type string did not match the following type: integer" }
    end

    context "subjects is an array of negative integers" do
      let(:json) { '{"subjects":[-132,-3154,-15343,-1]}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/subjects/0' did not have a minimum value of 0, inclusively" }
      it { expect(response_json['error'][1]).to include "The property '#/subjects/1' did not have a minimum value of 0, inclusively" }
      it { expect(response_json['error'][2]).to include "The property '#/subjects/2' did not have a minimum value of 0, inclusively" }
      it { expect(response_json['error'][3]).to include "The property '#/subjects/3' did not have a minimum value of 0, inclusively" }
    end

    context "subjects is an array of mostly positive integers, one negative" do
      let(:json) { '{"subjects":[123,643,1,43234,-1,1231]}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/subjects/4' did not have a minimum value of 0, inclusively" }
    end

    context "subjects is an array of positive integers" do 
      let(:json) { '{"subject":[123,643,1,43234,1,1231]}' }

      it { expect(response).to have_http_status(200) }
    end

    context "languages is a string" do
      let(:json) { '{"languages":"blargh"}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/languages' of type string did not match the following type: array" }
    end

    context "languages is an integer" do
      let(:json) { '{"languages":5}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/languages' of type integer did not match the following type: array" }
    end

    context "languages is an object" do
      let(:json) { '{"languages":{"foo":"bar"}}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/languages' of type object did not match the following type: array" }
    end

    context "languages is an array of strings" do
      let(:json) { '{"languages":["foo","bar"]}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/languages/0' of type string did not match the following type: integer" }
      it { expect(response_json['error'][1]).to include "The property '#/languages/1' of type string did not match the following type: integer" }
    end

    context "languages is an array of negative integers" do
      let(:json) { '{"languages":[-132,-3154,-15343,-1]}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/languages/0' did not have a minimum value of 0, inclusively" }
      it { expect(response_json['error'][1]).to include "The property '#/languages/1' did not have a minimum value of 0, inclusively" }
      it { expect(response_json['error'][2]).to include "The property '#/languages/2' did not have a minimum value of 0, inclusively" }
      it { expect(response_json['error'][3]).to include "The property '#/languages/3' did not have a minimum value of 0, inclusively" }
    end

    context "languages is an array of mostly positive integers, one negative" do
      let(:json) { '{"languages":[123,643,1,43234,-1,1231]}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/languages/4' did not have a minimum value of 0, inclusively" }
    end

    context "language is an array of positive integers" do 
      let(:json) { '{"languages":[123,643,1,43234,1,1231]}' }

      it { expect(response).to have_http_status(200) }
    end

    context "page_number is a string" do
      let(:json) { '{"page_number":"blargh"}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/page_number' of type string did not match the following type: integer" }
    end

    context "page_number is a negative integer" do
      let(:json) { '{"page_number":-235}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/page_number' did not have a minimum value of 0, inclusively" }
    end

    context "page_number is a positive integer" do
      let(:json) { '{"page_number":54}' }

      it { expect(response).to have_http_status(200) }
    end

    context "page_size is a string" do
      let(:json) { '{"page_size":"blargh"}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/page_size' of type string did not match the following type: integer" }
    end

    context "page_size is a negative integer" do
      let(:json) { '{"page_size":-918}' }

      it { expect(response).to have_http_status(402) }
      it { expect(response_json['status']).to include 'invalid' }
      it { expect(response_json['error'][0]).to include "The property '#/page_size' did not have a minimum value of 0, inclusively" }
    end

    context "page_size is a positive integer" do
      let(:json) { '{"page_size":918}' }

      it { expect(response).to have_http_status(200) }
    end
  end

  describe 'PUT #update' do


  end
end
