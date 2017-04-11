require 'test_helper'

class ComSignalTest < ActiveSupport::TestCase

  def setup
    CommunicationProtocol.create!(name: 'CAN', protocol_number: "1")
    QinesVersion.create!(name: 'V1.0', qines_version_number: "1")
    @project = Project.create!(id:1, name: 'testProject', communication_protocol_id: '1', qines_version_id: '1')
    @sign1   = Sign.create!(id:1, name: 'testSignal1', project:@project)
    @sign2   = Sign.create!(id:2, name: 'testSignal2', project:@project)
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

end
