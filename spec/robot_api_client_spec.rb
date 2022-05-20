require_relative "../robot_api_client"

RSpec.describe Robot do
  let(:robot) { Robot.new }
  context "get request" do
    it "returns status 200" do
      response = robot.http_get("http://localhost/", 3000, "/programing_languages", "username", "secretpassword")
      expect(response.code.to_i).to be(200)
    end
  end
end
