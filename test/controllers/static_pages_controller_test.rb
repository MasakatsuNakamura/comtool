require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @base_title = 'QINeS AUTOSAR Process Tools'
  end

  test 'should get root' do
    get root_path
    assert_response :success
  end

  # Home��Static�y�[�W�ł͂Ȃ����߃R�����g�A�E�gTODO:�������ӏ��ɋL�ڂ���
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

  # Contact path�͑��݂��Ȃ��̂ł�������R�����g�A�E�g�A�������ɃR�����g������
  #   test "should get contact" do
  #     get contact_path
  #     assert_response :success
  #     assert_select "title", "Contact | #{@base_title}"
  #   end
end
