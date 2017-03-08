require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title,         "QINeS AUTOSAR Process Tools"
    assert_equal full_title("Help"), "Help | QINeS AUTOSAR Process Tools"
  end
end
