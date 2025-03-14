require "rails_helper"

RSpec.describe "Creators", type: :request do
  before :all do
    13.times do
      FactoryBot.create(:creator) do |creator|
        FactoryBot.create_list(:link, 1, linkable: creator)
        FactoryBot.create_list(:model, 1, creator: creator)
      end
    end
  end
  describe "GET /creators?page=2" do
    it "returns paginated creators" do
      get "/creators?page=2"
      expect(response).to have_http_status(:success)
      expect(response.body).to match(/pagination/)
    end
  end
end
