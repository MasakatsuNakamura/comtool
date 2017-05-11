require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  def setup
    @project = Project.new(id:2, name: 'testProject1', communication_protocol_id: 'can', qines_version_id: 'v1_0')
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
    valid_names = %w[a z A Z name_0]
    valid_names.each do |name|
      @project.name = name
      assert @project.valid?, "#{name.inspect} should be valid"
    end
  end

  test "name validation should accept invalid name" do
    invalid_names = %w[0 9 _ _name_ 0name ! " # $ % & ' ( ) = ~ | \ [ ] @ * + < > ? ; : - * + ^ { }]
    invalid_names << 'na me'
    invalid_names << ' name'
    invalid_names << 'name '
    invalid_names.each do |name|
      @project.name = name
      assert @project.invalid?, "#{name.inspect} should be invalid"
    end
  end

  test "name should be unique" do
    assert @project.valid?
    duplicate_project = @project.dup
    @project.save
    assert_not duplicate_project.valid?

    duplicate_project.name = @project.name.upcase
    assert_not duplicate_project.valid?
  end

  test "name should be unique from sql" do
    project = Project.new(id:2, name: 'testProjectUnique', communication_protocol_id: 'can', qines_version_id: 'v1_0')
    project.save
    before_project_count = Project.all.length
    assert_raise(ActiveRecord::RecordNotUnique, "Not find exception") do
      con = ActiveRecord::Base.connection
      con.execute("INSERT INTO projects(name, communication_protocol_id, qines_version_id, created_at, updated_at) VALUES('TESTProjectUnique', '1', '1', 'Fri, 21 Apr 2017 15:40:43 JST +09:00', 'Fri, 21 Apr 2017 15:40:43 JST +09:00')")
    end
    after_project_count = Project.all.length
    assert_equal(before_project_count, after_project_count)
  end


end
