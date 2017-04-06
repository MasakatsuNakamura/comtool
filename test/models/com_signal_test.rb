require 'test_helper'

class ComSignalTest < ActiveSupport::TestCase

  def setup
    CommunicationProtocol.create!(name: 'CAN', protocol_number: "1")
    QinesVersion.create!(name: 'V1.0', qines_version_number: "1")
    @project = Project.create!(id:1, name: 'テストプロジェクト', communication_protocol_id: '1', qines_version_id: '1')
    @sign1   = Sign.create!(id:1, name: 'テスト符号1', project:@project)
    @sign2   = Sign.create!(id:2, name: 'テスト符号2', project:@project)
    @message = Message.create!(id:1, name: 'テストメッセージ', project:@project, bytesize:1, canid:1)

    @com_signal = ComSignal.new(
      name: 'Example ComSignal',
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
      name: 'Example ComSignal',
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
      name: 'Example ComSignal',
      message: @message,
      unit: 'Example Unit',
      description: 'Example Description',
      bit_size: 8,
      bit_offset: 7,
      )
    assert c.invalid?
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

  test "(bit_offset + bit_size) should be less than or equal to message.bytesize" do
    @message.bytesize = 1
    @message.save

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 0
    assert @com_signal.valid?

    @com_signal.bit_size = 9
    @com_signal.bit_offset = 0
    assert @com_signal.invalid?

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 8
    assert @com_signal.invalid?

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 9
    assert @com_signal.invalid?

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

    @message.save
    @com_signal.bit_size = 8
    @com_signal.bit_offset = 7
    assert @com_signal.valid?

    @message.bytesize = 2
    @message.save

    @com_signal.bit_size = 16
    @com_signal.bit_offset = 7
    assert @com_signal.valid?

    @message.bytesize = 3
    @message.save

    @com_signal.bit_size = 24
    @com_signal.bit_offset = 7
    assert @com_signal.valid?

    @message.bytesize = 4
    @message.save

    @com_signal.bit_size = 32
    @com_signal.bit_offset = 7
    assert @com_signal.valid?

    @com_signal.bit_size = 12
    @com_signal.bit_offset = 13
    assert @com_signal.valid?
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
end
