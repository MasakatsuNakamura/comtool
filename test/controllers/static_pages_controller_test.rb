require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = 'QINeS AUTOSAR Process Tools'
  end

  test 'should get root' do
    get root_path
    assert_response :success
  end

  # HomeはStaticページではないためコメントアウトTODO:正しい箇所に記載する
  # test 'should get home' do
  #   get home_index_path
  #   assert_response :success
  #   assert_select 'title', "Home | #{@base_title}"
  # end

  test 'should get help' do
    get help_path
    assert_response :success
    assert_select 'title', "Help | #{@base_title}"
  end

  test 'should get about' do
    get about_path
    assert_response :success
    assert_select 'title', "About | #{@base_title}"
  end

  # Contact pathは存在しないのでいったんコメントアウト、実装時にコメントを解除
  #   test "should get contact" do
  #     get contact_path
  #     assert_response :success
  #     assert_select "title", "Contact | #{@base_title}"
  #   end
end
