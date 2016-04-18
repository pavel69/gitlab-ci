require 'spec_helper'

describe API::API do
  include ApiHelpers

  describe 'POST /projects/:project_id/refs/:ref/trigger' do
    let!(:trigger_token) { 'secure token' }
    let!(:project) { FactoryGirl.create(:project) }
    let!(:project2) { FactoryGirl.create(:project) }
    let!(:trigger) { FactoryGirl.create(:trigger, project: project, token: trigger_token) }
    let(:options) {
      {
        token: trigger_token
      }
    }

    context 'Handles errors' do
      it 'should return bad request if token is missing' do
        post api("/projects/#{project.id}/refs/master/trigger")
        expect(response.status).to eq 400
      end

      it 'should return not found if project is not found' do
        post api('/projects/0/refs/master/trigger'), options
        expect(response.status).to eq 404
      end

      it 'should return unauthorized if token is for different project' do
        post api("/projects/#{project2.id}/refs/master/trigger"), options
        expect(response.status).to eq 401
      end
    end

    context 'Have a commit' do
      before do
        @commit = FactoryGirl.create(:commit, project: project)
      end

      it 'should create builds' do
        post api("/projects/#{project.id}/refs/master/trigger"), options
        expect(response.status).to eq 201
        @commit.builds.reload
        expect(@commit.builds.size).to eq 2
      end

      it 'should return bad request with no builds created if there\'s no commit for that ref' do
        post api("/projects/#{project.id}/refs/other-branch/trigger"), options
        expect(response.status).to eq 400
        expect(json_response['message']).to eq 'No builds created'
      end

      context 'Validates variables' do
        let(:variables) {
          {'TRIGGER_KEY' => 'TRIGGER_VALUE'}
        }

        it 'should validate variables to be a hash' do
          post api("/projects/#{project.id}/refs/master/trigger"), options.merge(variables: 'value')
          expect(response.status).to eq 400
          expect(json_response['message']).to eq 'variables needs to be a hash'
        end

        it 'should validate variables needs to be a map of key-valued strings' do
          post api("/projects/#{project.id}/refs/master/trigger"), options.merge(variables: {key: %w(1 2)})
          expect(response.status).to eq 400
          expect(json_response['message']).to eq 'variables needs to be a map of key-valued strings'
        end

        it 'create trigger request with variables' do
          post api("/projects/#{project.id}/refs/master/trigger"), options.merge(variables: variables)
          expect(response.status).to eq 201
          @commit.builds.reload
          expect(@commit.builds.first.trigger_request.variables).to eq variables
        end
      end
    end
  end
end
