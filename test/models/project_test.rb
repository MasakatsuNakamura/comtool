require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  def setup
    CommunicationProtocol.create!(name: 'CAN', protocol_number: "1")
    QinesVersion.create!(name: 'V1.0', qines_version_number: "1")
    @project = Project.new(id:1, name: 'testProject', communication_protocol_id: '1', qines_version_id: '1')
  end

  test "should be valid" do
    assert @project.valid?
  end

  test "name should be present" do
    @project.name = "     "
    assert_not @project.valid?
  end

  test "name should not be too long" do
    @project.name = "a" * 51
    assert_not @project.valid?
  end

  test "name validation should accept valid name" do
    valid_names = %w[a z A Z 0 9 _ _name_ name_0]
    valid_names.each do |name|
      @project.name = name
      assert @project.valid?, "#{name.inspect} should be valid"
    end
  end

  test "name validation should accept invalid name" do
    invalid_names = %w[! " # $ % & ' ( ) = ~ | \ [ ] @ * + < > ? ; : - * + ^ { }]
    invalid_names << 'na me'
    invalid_names << ' name'
    invalid_names << 'name '
    invalid_names.each do |name|
      @project.name = name
      assert @project.invalid?, "#{name.inspect} should be invalid"
    end
  end

end
