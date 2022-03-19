require 'rails_helper'

describe "Messages" do

  describe "Searching/querying/filtering a logged-in user's existing messages" do

    let!(:users) { create_list :user, 3 }
    let(:json) { {}.to_json }

    # 30 messages: ten from users 0 to 1; ten from 0 to 2; ten from 1 to 0.
    before do
      (1..10).each do |i|
        create :message, 
          messager: users[0], 
          messagee: users[1], 
          created_at: i.days.ago, 
          seen_at: i>7 ? nil : i.days.ago # Random smattering of seen_at
        create :message, 
          messager: users[0], 
          messagee: users[2], 
          created_at: i.days.ago, 
          seen_at: i>5 ? nil : i.days.ago # Random smattering of seen_at
        create :message, 
          messager: users[1], 
          messagee: users[0], 
          created_at: i.days.ago,
          seen_at: i>3 ? nil : i.days.ago # Random smattering of seen_at
      end

    end

    context "Logged in as users[0]" do

      before { 
        post search_messages_path,
          params: json,
          headers: jwt_headers_for(users[0]) 
      }

      context "No search params at all" do

        let(:json) { '' }

        it { expect(response).to have_http_status(200) }

        it "returns all 20 of user0's messages" do
          twenty_mrs_expected = Message.where(messager_id: users[0].id)
            .limit(20)
            .offset(0)
            .order('updated_at desc')
            .map {|m| MessageResource.new(m, nil) }
          twenty_smrs_expected = JSONAPI::ResourceSerializer.new(
              MessageResource, 
              { include: ['messager', 'messagee'] }
            ).serialize_to_hash(twenty_mrs_expected)
             .deep_stringify_keys!
          
          expect(response_json).to eq twenty_smrs_expected
        end
      end

      context "Search param: messagee_id" do

        context "Happy params" do

          context "messagee_id=users[1].id" do

            let(:json) { { messagee_id: users[1].id }.to_json }

            it { expect(response).to have_http_status(200) }

            it "returns the 10 messages where messager=users0, messagee=users1" do
              ten_mrs_expected = Message.where(messager_id: users[0].id, messagee_id: users[1].id)
                .limit(10)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              ten_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource,
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(ten_mrs_expected)
                 .deep_stringify_keys!

              expect(response_json).to eq ten_smrs_expected
            end
          end

          context "messagee_id=users[2].id" do

            let(:json) { { messagee_id: users[2].id }.to_json }

            it { expect(response).to have_http_status(200) }

            it "returns the 10 messages where messager=users0, messagee=users2" do
              ten_mrs_expected = Message.where(messager_id: users[0].id, messagee_id: users[2].id)
                .limit(10)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              ten_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(ten_mrs_expected)
                 .deep_stringify_keys!

              expect(response_json).to eq ten_smrs_expected
            end
          end

          context "messagee_id=users[0].id" do

            let(:json) { { messagee_id: users[0].id }.to_json }

            it { expect(response).to have_http_status(200) }
            it "returns 0 messages" do
              expect(response_json).to eq({ 'data' => [] })
            end
          end

          context "messagee_id=999999" do

            let(:json) { { messagee_id: 999999 }.to_json }

            it { expect(response).to have_http_status(200) }
            it "returns 0 messages" do
              expect(response_json).to eq({ 'data' => [] })
            end
          end
        end

        context "Sad params" do

          context "messagee_id is a negative integer" do

            let(:json) { { messagee_id: -5000 }.to_json }

            it { expect(response).to have_http_status(402) }
            it { expect(response_json['status']).to include 'invalid' }
            it "returns an explanatory error" do
              expect(response_json['error'][0])
              .to include "The property '#/messagee_id' did not have a minimum value of 1, inclusively"
            end
          end

          context "messagee_id is a positive float" do

            let(:json) { { messagee_id: 500.04 }.to_json }

            it { expect(response).to have_http_status(402) }
            it { expect(response_json['status']).to include 'invalid' }
            it "returns an explanatory error" do
              expect(response_json['error'][0])
              .to include "The property '#/messagee_id' of type number did not match the following type: integer"
            end
          end

          context "messagee_id is an array" do

            let(:json) { { messagee_id: ['2', '4', '6'] }.to_json }

            it { expect(response).to have_http_status(402) }
            it { expect(response_json['status']).to include 'invalid' }
            it "returns an explanatory error" do
              expect(response_json['error'][0])
              .to include "The property '#/messagee_id' of type array did not match the following type: integer"
            end
          end
        end
      end

      context "Search param: after" do

        context "Happy params" do

          let(:json) { { after: after.rfc3339 }.to_json }

          context "after is 30 days ago: earlier than every message" do

            let(:after) { 30.days.ago }

            it { expect(response).to have_http_status(200) }

            it "returns all 20 of user0's messages" do
              all_20_mrs_expected = Message.where(messager_id: users[0].id)
                .where('created_at > ?', after)
                .limit(20)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              all_20_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(all_20_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq all_20_smrs_expected
            end
          end

          context "after is 4.5 days ago: earlier than 10" do

            let(:after) { (4.5).days.ago }
            
            it { expect(response).to have_http_status(200) }

            it "returns only the most recent 10 of user0's messages" do
              most_recent_10_mrs_expected = Message.where(messager_id: users[0].id)
                .where('created_at > ?', after)
                .limit(10)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              most_recent_10_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(most_recent_10_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq most_recent_10_smrs_expected
            end
          end

          context "after is 3 days ahead: earlier than zero" do

            let(:after) { 3.days.from_now }
            
            it { expect(response).to have_http_status(200) }

            it "returns ZERO of user0's messages" do
              zero_future_mrs_expected = Message.where(messager_id: users[0].id)
                .where('created_at > ?', after)
                .limit(0) # limit zero :D
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              zero_future_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(zero_future_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq zero_future_smrs_expected
            end
          end
        end

        context "Sad params" do

          context "after is not a date string" do

            let(:json) { { after: 'wefjewf' }.to_json }

            it { expect(response).to have_http_status(402) }
            it { expect(response_json['status']).to include 'invalid' }
            it "returns an explanatory error" do
              expect(response_json['error'][0])
              .to include "The property '#/after' must be a valid RFC3339 date/time string"
            end
          end
        end
      end

      context "Search param: before" do

        context "Happy params" do

          let(:json) { { before: before.rfc3339 }.to_json }

          context "before is 30 days ago" do

            let(:before) { 30.days.ago }

            it { expect(response).to have_http_status(200) }

            it "returns zero of user0's messages" do
              zero_mrs_expected = Message.where(messager_id: users[0].id)
                .where('created_at < ?', before)
                .limit(0)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              zero_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(zero_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq zero_smrs_expected
            end
          end

          context "before is 4.5 days ago" do

            let(:before) { (4.5).days.ago }

            it { expect(response).to have_http_status(200) }

            it "returns 12 of user0's messages" do
              twelve_mrs_expected = Message.where(messager_id: users[0].id)
                .where('created_at < ?', before)
                .limit(12)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              twelve_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(twelve_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq twelve_smrs_expected
            end
          end

          context "before is 3 days ahead" do

            let(:before) { 3.days.from_now }

            it { expect(response).to have_http_status(200) }

            it "returns all 20 of user0's messages" do
              twenty_mrs_expected = Message.where(messager_id: users[0].id)
                .where('created_at < ?', before)
                .limit(20)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              twenty_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(twenty_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq twenty_smrs_expected
            end
          end
        end
      end

      context "Search param: combining after and before" do

        let(:json) { 
          { before: before.rfc3339,
             after: after.rfc3339 }.to_json 
        }

        context "Happy params" do

          context "after: 30 days ago; before: 4.5 days ago" do

            let(:before) { 30.days.ago }
            let(:after) { (4.5).days.ago }

            it "returns 12 of user0's messages" do
              twelve_mrs_expected = Message.where(messager_id: users[0].id)
                .where('created_at < ?', before)
                .where('created_at > ?', after)
                .limit(12)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              twelve_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(twelve_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq twelve_smrs_expected
            end
          end
        end

        context "Sad params" do

          context "after: 4.5 days ago; before: 30 days ago" do

            let(:before) { (4.5).days.ago }
            let(:after) { 30.days.ago }

            it { expect(response).to have_http_status(402) }
            it { expect(response_json['status']).to include 'invalid' }
            it "returns an explanatory error" do
              expect(response_json['error'][0])
              .to include "The property '#/before' can't be more recent than '#/after, now can it, sweetie-darling"
            end
          end
        end
      end

      context "Search param: seen" do 

        let(:json) { { seen: seen }.to_json }

        context "Happy params" do

          context "seen is true" do

            let(:seen) { true }

            it { expect(response).to have_http_status(200) }

            it "returns twelve of user0's messages" do
              twelve_mrs_expected = Message.where(messager_id: users[0].id)
                .where('seen_at IS NOT NULL')
                .limit(12)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              twelve_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(twelve_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq twelve_smrs_expected
            end
          end

          context "seen is false" do

            let(:seen) { false }

            it { expect(response).to have_http_status(200) }

            it "returns eight of user0's messages" do
              eight_mrs_expected = Message.where(messager_id: users[0].id)
                .where('seen_at IS NULL')
                .limit(8)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              eight_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(eight_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq eight_smrs_expected
            end
          end
        end

        context "Sad params" do

          context "seen is non-boolean" do

            let(:seen) { 'blargh' }

            it { expect(response).to have_http_status(402) }
            it { expect(response_json['status']).to include 'invalid' }
            it "returns an explanatory error" do
              expect(response_json['error'][0])
              .to include "The property '#/seen' of type string did not match the following type: boolean"
            end
          end
        end
      end

      context "Search params: page_number, page size" do

        let(:json) { { page_number: page_number, page_size: page_size }.to_json }

        context "Happy params" do

          context "page size is 4, page_number is 0" do

            let(:page_size) { 4 }
            let(:page_number) { 0 }

            it { expect(response).to have_http_status(200) }

            it "returns the first set of four of user0's messages" do
              first_set_of_four_mrs_expected = Message.where(messager_id: users[0].id)
                .limit(4)
                .offset(0)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              first_set_of_four_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(first_set_of_four_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq first_set_of_four_smrs_expected
            end
          end

          context "page size is 3, page number is 2" do 

            let(:page_size) { 3 }
            let(:page_number) { 2 }

            it { expect(response).to have_http_status(200) }

            it "returns the third set of three of user0's messages" do
              third_set_of_three_mrs_expected = Message.where(messager_id: users[0].id)
                .limit(3)
                .offset(6)
                .order('updated_at desc')
                .map {|m| MessageResource.new(m, nil) }
              third_set_of_three_smrs_expected = JSONAPI::ResourceSerializer.new(
                  MessageResource, 
                  { include: ['messager', 'messagee'] }
                ).serialize_to_hash(third_set_of_three_mrs_expected)
                 .deep_stringify_keys!
              
              expect(response_json).to eq third_set_of_three_smrs_expected
            end
          end
        end

        context "Sad params" do

          context "page size and page number are both strings" do

            let(:page_size) { 'blargh the first' }
            let(:page_number) { 'blargh the second' }

            it { expect(response).to have_http_status(402) }
            it { expect(response_json['status']).to include 'invalid' }
            it "returns an explanatory error for page_number" do
              expect(response_json['error'][0])
              .to include "The property '#/page_number' of type string did not match the following type: integer"
            end
            it "returns an explanatory error for page_size" do
              expect(response_json['error'][1])
              .to include "The property '#/page_size' of type string did not match the following type: integer"
            end
          end
        end
      end
    end

    context "Logged in as users[1], no params" do

      before { 
        post '/messages/search', headers: jwt_headers_for(users[1])
      }

      it { expect(response.status).to eq 200 }

      it "returns all ten of users[1]'s received_messages" do
        ten_mrs_expected = Message.where(messager_id: users[1].id)
          .limit(10)
          .offset(0)
          .order('updated_at desc')
          .map {|m| MessageResource.new(m, nil) }
        ten_smrs_expected = JSONAPI::ResourceSerializer.new(
            MessageResource, 
            { include: ['messager', 'messagee'] }
          ).serialize_to_hash(ten_mrs_expected)
           .deep_stringify_keys!
        
        expect(response_json).to eq ten_smrs_expected
      end
    end

    context "Not logged in" do
      before { post '/messages/search', headers: { 'Logged-In-?': 'Nah' } }
      it { expect(response.status).to eq 401 }
    end
  end

  describe "Creating a new message" do

    let!(:messager) { create :user }
    let!(:messagee) { create :user }
    
    context "Logged in" do

      before do
        post '/messages', 
          headers: jwt_headers_for(messager), 
          params: { message: message_attrs }.to_json
      end

      context "Happy params" do

        let!(:message_attrs) do
          attributes_for :message, messagee_id: messagee.id
        end

        it { expect(response.status).to eq 200 }
        it "creates and returns a new Message object with messager=current_user" do
          expect(response_json['data']['relationships']['messager']['data']['id'])
            .to eq messager.id.to_s
        end

        it "creates and returns a new Message object with messagee=params[messagee]" do
          expect(response_json['data']['relationships']['messagee']['data']['id'])
            .to eq messagee.id.to_s
        end
      end

      context "Sad params" do

        context "Content is missing" do

          let!(:message_attrs) do
            attributes_for(:message, messagee_id: messagee.id).except!(:content)
          end

          it { expect(response.status).to eq 422 }
          it "returns an error message complaining about the lack of content" do
            expect(response_json['errors']).to eq({ "content" => ["can't be blank"] })
          end
        end

        context "Messagee ID is missing" do

          let!(:message_attrs) do
            attributes_for(:message).except!(:messagee_id)
          end

          it { expect(response.status).to eq 422 }
          it "returns an error message complaining about the missing messagee ID" do
            expect(response_json['errors']).to eq({ "messagee" => ["must exist"] })
          end
        end
      end
    end

    context "Not logged in" do
      before { post '/messages', headers: { 'Logged-In-?': 'Nah' } }
      it { expect(response.status).to eq 401 }
    end
  end


  # Most common use case: populating Message#seen_at: defaults to nil, but becomes a # timestamp when viewed from the client. 
  describe "Updating an existing message" do

    let(:messager) { create :user }
    let(:messagee) { create :user }
    let(:message) { create :message, messager: messager, messagee: messagee }
    let(:seen_at_timestamp) { 
      Faker::Time.between(from: Time.now - 1.week, to: Time.now + 1.week).to_s 
    }

    context "Logged in" do
      context "current_user is messager" do

        before {
          put "/messages/#{message.id}", 
            headers: jwt_headers_for(messager),
            params: { seen_at: seen_at_timestamp }.to_json
          message.reload
        }

        it { expect(response.status).to eq 200 }
        it "returns the message JSON" do
          expected_smr = JSONAPI::ResourceSerializer.new(
            MessageResource, 
            { include: ['messager', 'messagee'] }
          ).serialize_to_hash(
            MessageResource.new(message, nil)
          )

          expect(response_json['data'])
            .to eq expected_smr.deep_stringify_keys!['data']
        end
      end

      context "current_user is messagee" do

        before {
          put "/messages/#{message.id}", 
            headers: jwt_headers_for(messagee),
            params: { seen_at: seen_at_timestamp }.to_json
          message.reload
        }

        it { expect(response.status).to eq 200 }
        it "returns the message JSON" do
          expected_smr = JSONAPI::ResourceSerializer.new(
            MessageResource, 
            { include: ['messager', 'messagee'] }
          ).serialize_to_hash(
            MessageResource.new(message, nil)
          )

          expect(response_json['data'])
            .to eq expected_smr.deep_stringify_keys!['data']
        end
      end

      context "current_user is totally unrelated user" do

        let(:totally_unrelated_user) { create :user }

        before {
          put "/messages/#{message.id}", 
            headers: jwt_headers_for(totally_unrelated_user),
            params: { seen_at: seen_at_timestamp }.to_json
        }

        it { expect(response.status).to eq 403 }
      end
    end

    context "Not logged in at all" do
      before { put "/messages/#{message.id}", headers: { 'Logged-In-?': 'Nah' } }
      it { expect(response.status).to eq 401 }
    end
  end

  describe "Deleting a message" do

    let(:messager) { create :user }
    let(:messagee) { create :user }
    let(:message) { create :message, messager: messager, messagee: messagee }

    context "Logged in" do
      context "current_user is messager" do

        before {
          delete "/messages/#{message.id}", 
            headers: jwt_headers_for(messager)
        }

        it { expect(response.status).to eq 200 }
        it "returns the message JSON" do
          expected_smr = JSONAPI::ResourceSerializer.new(
            MessageResource, 
            { include: ['messager', 'messagee'] }
          ).serialize_to_hash(
            MessageResource.new(message, nil)
          )

          expect(response_json['data'])
            .to eq expected_smr.deep_stringify_keys!['data']
        end
      end

      context "current_user is messagee" do

        before {
          delete "/messages/#{message.id}", 
            headers: jwt_headers_for(messagee)
        }

        it { expect(response.status).to eq 200 }
        it "returns the message JSON" do
          expected_smr = JSONAPI::ResourceSerializer.new(
            MessageResource, 
            { include: ['messager', 'messagee'] }
          ).serialize_to_hash(
            MessageResource.new(message, nil)
          )

          expect(response_json['data'])
            .to eq expected_smr.deep_stringify_keys!['data']
        end
      end

      context "current_user is totally unrelated user" do

        let(:totally_unrelated_user) { create :user }

        before {
          delete "/messages/#{message.id}", 
            headers: jwt_headers_for(totally_unrelated_user)
        }

        it { expect(response.status).to eq 403 }
      end
    end

    context "Not logged in at all" do
      before { delete "/messages/#{message.id}", headers: { 'Logged-In-?': 'Nah' } }
      it { expect(response.status).to eq 401 }
    end
  end
end