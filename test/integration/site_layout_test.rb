require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    # HOME���O�C���p���[�U�[�̍쐬
    # user = users(:michael)
    u_params ={ name: "Michael Example", email: "michael@example.com", password: "password", password_confirmation: "password"}
    @user = User.create!(u_params)
  end

  test 'layout links' do
    get signin_path
    post sessions_path, params: { session: { name: @user.name,
                                             password: 'password' } }
    # assert_redirected_to @user
    follow_redirect!
    assert_template 'home/index'

    assert_select 'a[href=?]', root_path, count: 0
    # HOME INDEX PATH�̃����N��1�����Ȃ��Ǝv������
    # assert_select 'a[href=?]', projects_path, count: 2
    assert_select 'a[href=?]', projects_path, count: 1
    assert_select 'a[href=?]', help_path, count: 1
    # ABOUT PATH�̃����N��1�����Ȃ��Ǝv������
    # assert_select 'a[href=?]', about_path, count: 2
    assert_select 'a[href=?]', about_path, count: 1
    # CONTACT PATH �̃����N�͎��������Ă��Ȃ��̂ŃR�����g�A�E�g
    # assert_select 'a[href=?]', contact_path, count: 1
  end

  test 'access signup' do
    get root_path
    get signup_path
    # Sig��Up���̃^�C�g����SignUp�������̂ŃR�����g�A�E�g
    # assert_select "title", full_title("Sign up")
  end
end
