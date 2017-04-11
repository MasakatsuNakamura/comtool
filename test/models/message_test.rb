require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def setup
    CommunicationProtocol.create!(name: 'CAN', protocol_number: "1")
    QinesVersion.create!(name: 'V1.0', qines_version_number: "1")
    @project = Project.create!(id:1, name: 'testProject', communication_protocol_id: '1', qines_version_id: '1')
    @sign1   = Sign.create!(id:1, name: 'testSignal1', project:@project)
    @sign2   = Sign.create!(id:2, name: 'testSignal2', project:@project)

    @message = Message.new(name: 'testMessage', project:@project, bytesize:1,canid:1)
  end

  test "should be valid" do
    assert @message.valid?
  end

  test "message layout should not be overlap" do
    msg = Message.new(name: 'testMessage', project:@project, bytesize:1,canid:1)
    c1 = msg.com_signals.build(
      name: "c1",
      message: msg,
      bit_size: 1,
      bit_offset: 0,
      sign: @sign1
      )

    c2 = msg.com_signals.build(
      name: "c2",
      message: msg,
      bit_size: 1,
      bit_offset: 1,
      sign: @sign2
      )

    assert msg.valid?

    c2.bit_size = 1
    c2.bit_offset = 0
    assert msg.invalid?

    # TODO:little_endian
=begin
    @message.byte_order = :little_endian
    @com_signal.bit_size = 7
    @com_signal.bit_offset = 1
    assert msg.valid?
=end

=begin
    @message.byte_order = :big_endian
=end
    c2.bit_size = 7
    c2.bit_offset = 7
    assert msg.valid?
  end

  test "name validation should accept valid name" do
    valid_names = %w[a z A Z name_0]
    valid_names.each do |name|
      @message.name = name
      assert @message.valid?, "#{name.inspect} should be valid"
    end
  end

  test "name validation should accept invalid name" do
    invalid_names = %w[0 9 _ _name_ 0name ! " # $ % & ' ( ) = ~ | \ [ ] @ * + < > ? ; : - * + ^ { }]
    invalid_names << 'na me'
    invalid_names << ' name'
    invalid_names << 'name '
    invalid_names.each do |name|
      @message.name = name
      assert @message.invalid?, "#{name.inspect} should be invalid"
    end
  end


  test "(bit_offset + bit_size) should be less than or equal to message.bytesize" do
    @com_signal = @message.com_signals.build(
      name: "c1",
      message: @message,
      bit_size: 1,
      bit_offset: 0,
      sign: @sign1
      )

    assert @message.valid?
    assert @com_signal.valid?

    @message.bytesize = 1

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 0
    assert @message.valid?

    @com_signal.bit_size = 9
    @com_signal.bit_offset = 0
    assert @message.invalid?

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 8
    assert @message.invalid?

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 9
    assert @message.invalid?

    # TODO:little_endian
=begin
    @message.byte_order = :little_endian
    @com_signal.bit_size = 8
    @com_signal.bit_offset = 0
    assert @com_signal.valid?
=end

# TODO:little_endian
=begin
    @message.byte_order = :big_endian
=end

    @message.bytesize = 1

    @com_signal.bit_size = 8
    @com_signal.bit_offset = 7
    assert @message.valid?

    @com_signal.bit_size = 9
    @com_signal.bit_offset = 7
    assert @message.invalid?

    @message.bytesize = 2

    @com_signal.bit_size = 16
    @com_signal.bit_offset = 7
    assert @message.valid?

    @com_signal.bit_size = 17
    @com_signal.bit_offset = 7
    assert @message.invalid?

    @message.bytesize = 8

    @com_signal.bit_size = 64
    @com_signal.bit_offset = 7
    assert @message.valid?

    @com_signal.bit_size = 65
    @com_signal.bit_offset = 7
    assert @message.invalid?

    @com_signal.bit_size = 12
    @com_signal.bit_offset = 13
    assert @message.valid?
  end

end
