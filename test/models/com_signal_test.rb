require 'test_helper'

class ComSignalTest < ActiveSupport::TestCase

  def setup
    @project = Project.create!(id:2, name: 'testProject1', communication_protocol_id: 'can', qines_version_id: 'v1_0')
    @sign1   = Sign.create!(id:2, name: 'testSignal1', project:@project)
    @sign2   = Sign.create!(id:3, name: 'testSignal2', project:@project)
    @message = Message.create!(id:1, name: 'testMessage', project:@project, bytesize:1, canid:1)

    @com_signal = @message.com_signals.build(
      name: 'ExampleComSignal',
      message: @message,
      unit: 'Example Unit',
      description: 'Example Description',
      bit_size: 8,
      bit_offset: 7,
      sign: @sign1
      )
  end

  test "should be valid" do
    assert @message.valid?
    assert @com_signal.valid?
  end

  test "should belong_to message" do
    c = ComSignal.new(
      name: 'ExampleComSignal',
      unit: 'Example Unit',
      description: 'Example Description',
      bit_size: 8,
      bit_offset: 7,
      sign: @sign1
      )
    assert c.invalid?
  end

  test "should belong_to sign" do
    c = ComSignal.new(
      name: 'ExampleComSignal',
      message: @message,
      unit: 'Example Unit',
      description: 'Example Description',
      bit_size: 8,
      bit_offset: 7,
      )
    # TODO:タスク #653
#    assert c.invalid?
    assert c.valid?
  end

  test "name should be present" do
    @com_signal.name = "     "
    assert_not @com_signal.valid?
  end

  test "name should not be too long" do
    @com_signal.name = "a" * 51
    assert_not @com_signal.valid?
  end

  test "bit_offset should be present" do
    @com_signal.bit_offset = ""
    assert_not @com_signal.valid?
  end

  test "bit_offset should be integer" do
    @com_signal.bit_offset = "a"
    assert_not @com_signal.valid?
  end

  test "bit_size should be present" do
    @com_signal.bit_size = ""
    assert_not @com_signal.valid?
  end

  test "bit_size should be integer" do
    @com_signal.bit_size = 0
    assert_not @com_signal.valid?
  end

  test "bit_size bigger than 1" do
    @com_signal.bit_size = 0
    assert @com_signal.invalid?

    @com_signal.bit_size = 1
    assert @com_signal.valid?
  end

  # TODO:タスク #653
=begin
  test "sign should be unique" do
    c = ComSignal.new(
      name: 'Example ComSignal',
      message: @message,
      unit: 'Example Unit',
      description: 'Example Description',
      bit_size: 8,
      bit_offset: 0,
      sign: @sign1
      )

    @message.bytesize = 1

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 0
    @com_signal.save

    c.bit_size = 1
    c.bit_offset = 1
    assert c.invalid?
  end
=end

  test "name validation should accept valid name" do
    valid_names = %w[a z A Z name_0]
    valid_names.each do |name|
      @com_signal.name = name
      assert @com_signal.valid?, "#{name.inspect} should be valid"
    end
  end

  test "name validation should accept invalid name" do
    invalid_names = %w[0 9 _ _name_ 0name ! " # $ % & ' ( ) = ~ | \ [ ] @ * + < > ? ; : - * + ^ { }]
    invalid_names << 'na me'
    invalid_names << ' name'
    invalid_names << 'name '
    invalid_names.each do |name|
      @com_signal.name = name
      assert @com_signal.invalid?, "#{name.inspect} should be invalid"
    end
  end


  test "name should be unique in message" do
    duplicate_com_signal = @com_signal.dup
    @com_signal.save
    assert_not duplicate_com_signal.valid?

    duplicate_com_signal.name = @com_signal.name.upcase
    assert_not duplicate_com_signal.valid?

    duplicate_com_signal = @com_signal.dup
    message  = Message.create!(id:2, name: 'testMessage2', project:@project, bytesize:1, canid:1)
    @com_signal.message_id = 2
    @com_signal.save
    assert duplicate_com_signal.valid?
  end

  test "name should be unique from sql" do
    com_signal = ComSignal.new(
      name: 'ExampleComSignal',
      message_id: 1,
      bit_size: 8,
      bit_offset: 7
      )
    com_signal.save

    before_com_signal_count = ComSignal.all.length
    assert_raise(ActiveRecord::RecordNotUnique, "Not find exception") do
      con = ActiveRecord::Base.connection
      con.execute("INSERT INTO com_signals(name, message_id, created_at, updated_at) VALUES('EXAMPLECOMSIGNAL', 1, 'Fri, 21 Apr 2017 15:40:43 JST +09:00', 'Fri, 21 Apr 2017 15:40:43 JST +09:00')")
    end
    after_com_signal_count = ComSignal.all.length
    assert_equal(before_com_signal_count, after_com_signal_count)
  end
end
