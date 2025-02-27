# frozen_string_literal: true

require 'rails_helper'

describe 'updateConsignmentSubmission mutation' do
  let(:user) { Fabricate(:user, gravity_user_id: 'userid') }
  let(:submission) do
    attrs = {
      artist_id: 'abbas-kiarostami',
      category: 'Painting',
      state: 'draft',
      title: 'rain',
      user: user
    }

    Fabricate(:submission, attrs)
  end

  let(:token) do
    payload = { aud: 'gravity', sub: user.gravity_user_id, roles: 'user' }
    JWT.encode(payload, Convection.config.jwt_secret)
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:mutation_inputs) do
    "{ state: DRAFT, category: JEWELRY, clientMutationId: \"test\", id: #{
      submission.id
    }, artistID: \"andy-warhol\", title: \"soup\" }"
  end

  let(:mutation) { <<-GRAPHQL }
    mutation {
      updateConsignmentSubmission(input: #{mutation_inputs}){
        clientMutationId
        consignmentSubmission {
          category
          state
          id
          artistId
          title
          locationPostalCode
          locationCountryCode
        }
      }
    }
  GRAPHQL

  describe 'requests' do
    context 'with an unauthorized request' do
      let(:token) { 'foo.bar.baz' }

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        error_message = body['errors'][0]['message']
        expect(error_message).to eq 'Submission Not Found'
      end
    end

    context 'with a request missing an app token' do
      let(:token) do
        payload = { sub: 'userid', roles: 'user' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        update_response = body['data']['updateConsignmentSubmission']
        expect(update_response).to_not eq nil
      end
    end

    context 'with a request updating your own submission' do
      let(:user1) { Fabricate(:user, gravity_user_id: 'userid3') }
      let(:submission1) do
        attrs = {
          artist_id: 'abbas-kiarostami',
          category: 'Painting',
          state: 'draft',
          title: 'rain',
          user: user1,
          session_id: 'token'
        }
        Fabricate(:submission, attrs)
      end
      let(:mutation_inputs) do
        "{ state: DRAFT, category: JEWELRY, clientMutationId: \"test\", id: #{
          submission1.id
        }, artistID: \"andy-warhol\", title: \"soup\", sessionID: \"diff token\" }"
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        update_response = body['data']['updateConsignmentSubmission']
        expect(update_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq 'Submission Not Found'
      end
    end

    context 'with a request updating your own submission' do
      let(:user1) { Fabricate(:user, gravity_user_id: 'userid4') }
      let(:token) do
        payload = { aud: 'gravity', sub: user1.gravity_user_id, roles: 'user' }
        JWT.encode(payload, Convection.config.jwt_secret)
      end
      let(:submission1) do
        attrs = {
          artist_id: 'abbas-kiarostami',
          category: 'Painting',
          state: 'draft',
          title: 'rain',
          user: user1,
          session_id: 'token'
        }
        Fabricate(:submission, attrs)
      end
      let(:mutation_inputs) do
        "{ category: JEWELRY, clientMutationId: \"test\", id: #{
          submission1.id
        }, artistID: \"andy-warhol\", title: \"soup\", sessionID: \"token\" }"
      end

      it 'returns updated submission' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        update_response = body['data']['updateConsignmentSubmission']
        expect(update_response).to_not eq nil
      end
    end

    context 'with an invalid submission id' do
      let(:mutation_inputs) do
        '{ clientMutationId: "test", id: 999999, artistID: "andy-warhol", title: "soup" }'
      end

      it 'returns an error for that request' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        update_response = body['data']['updateConsignmentSubmission']
        expect(update_response).to eq nil

        error_message = body['errors'][0]['message']
        expect(error_message).to eq 'Submission Not Found'
      end
    end

    context 'with a submission not in draft state' do
      let(:user1) { Fabricate(:user, gravity_user_id: 'userid4') }

      let(:submission1) do
        attrs = {
          artist_id: 'abbas-kiarostami',
          category: 'Painting',
          state: 'submitted',
          title: 'rain',
          user: user1,
          session_id: 'token'
        }
        Fabricate(:submission, attrs)
      end
      let(:mutation_inputs) do
        "{ category: JEWELRY, clientMutationId: \"test\", id: #{
          submission1.id
        }, artistID: \"andy-warhol\", title: \"soup\", sessionID: \"token\" }"
      end

      context 'if admin' do
        let(:token) do
          payload = {
            aud: 'gravity',
            sub: user1.gravity_user_id,
            roles: 'admin'
          }
          JWT.encode(payload, Convection.config.jwt_secret)
        end

        it 'returns an error for that request' do
          post '/api/graphql', params: { query: mutation }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          submission_response =
            body['data']['updateConsignmentSubmission']['consignmentSubmission']
          expect(submission_response).to include(
            {
              'id' => submission1.id.to_s,
              'title' => 'soup',
              'artistId' => 'andy-warhol',
              'category' => 'Jewelry',
              'state' => 'SUBMITTED'
            }
          )
        end
      end

      context 'if submission owner' do
        let(:token) do
          payload = {
            aud: 'gravity',
            sub: user1.gravity_user_id,
            roles: 'user'
          }
          JWT.encode(payload, Convection.config.jwt_secret)
        end
        it 'returns an error for that request' do
          post '/api/graphql', params: { query: mutation }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          update_response = body['data']['updateConsignmentSubmission']
          expect(update_response).to eq nil

          error_message = body['errors'][0]['message']
          expect(error_message).to eq 'Submission Not Found'
        end
      end
    end

    describe 'valid requests' do
      it 'updates the submission' do
        post '/api/graphql', params: { query: mutation }, headers: headers

        expect(response.status).to eq 200
        body = JSON.parse(response.body)

        submission_response =
          body['data']['updateConsignmentSubmission']['consignmentSubmission']
        expect(submission_response).to include(
          {
            'id' => submission.id.to_s,
            'title' => 'soup',
            'artistId' => 'andy-warhol',
            'category' => 'Jewelry',
            'state' => 'DRAFT'
          }
        )
      end

      context 'postal code' do
        let(:mutation_inputs) do
          "{  clientMutationId: \"test\", id: \"#{
            submission.id
          }\", locationPostalCode: \"12345\" }"
        end

        it 'updates successfull' do
          post '/api/graphql', params: { query: mutation }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          submission_response =
            body['data']['updateConsignmentSubmission']['consignmentSubmission']
          expect(submission_response).to include(
            {
              'id' => submission.id.to_s,
              'title' => 'rain',
              'artistId' => 'abbas-kiarostami',
              'category' => 'Painting',
              'state' => 'DRAFT',
              'locationPostalCode' => '12345'
            }
          )
        end
      end

      context 'country code' do
        let(:mutation_inputs) do
          "{  clientMutationId: \"test\", id: \"#{
            submission.id
          }\", locationCountryCode: \"us\" }"
        end

        it 'updates successfull' do
          post '/api/graphql', params: { query: mutation }, headers: headers

          expect(response.status).to eq 200
          body = JSON.parse(response.body)

          submission_response =
            body['data']['updateConsignmentSubmission']['consignmentSubmission']
          expect(submission_response).to include(
            {
              'id' => submission.id.to_s,
              'title' => 'rain',
              'artistId' => 'abbas-kiarostami',
              'category' => 'Painting',
              'state' => 'DRAFT',
              'locationCountryCode' => 'us'
            }
          )
        end
      end
    end
  end

  context 'when working with external id' do
    describe 'successfull scenario' do
      let(:mutation_inputs) do
        "{ state: DRAFT, clientMutationId: \"test\", externalId: \"#{
          submission.uuid
        }\", title: \"soup\" }"
      end

      let(:mutation) { <<-GRAPHQL }
        mutation {
          updateConsignmentSubmission(input: #{mutation_inputs}){
            clientMutationId
            consignmentSubmission {
              title
              externalId
            }
          }
        }
      GRAPHQL

      it 'updates submission' do
        post '/api/graphql', params: { query: mutation }, headers: headers
        expect(response.status).to eq 200

        response_body = JSON.parse(response.body)
        updated_data =
          response_body['data']['updateConsignmentSubmission'][
            'consignmentSubmission'
          ]

        expect(updated_data['title']).to eq('soup')
        expect(updated_data['externalId']).to eq(submission.uuid)
      end
    end
  end
end
