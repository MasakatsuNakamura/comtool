require 'test_helper'

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    @project = Project.create!(id:1, name: 'testProject1', communication_protocol_id: 'can', qines_version_id: 'v1_0')
    get new_project_message_path(@project)
    assert_response :success
  end

end
