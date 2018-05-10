require 'test_helper'

class MazeControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get maze_create_url
    assert_response :success
  end

  test "should get show" do
    get maze_show_url
    assert_response :success
  end

end
