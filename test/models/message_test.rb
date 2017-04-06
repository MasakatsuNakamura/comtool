require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def setup
    CommunicationProtocol.create!(name: 'CAN', protocol_number: "1")
    QinesVersion.create!(name: 'V1.0', qines_version_number: "1")
    @project = Project.create!(id:1, name: 'テストプロジェクト', communication_protocol_id: '1', qines_version_id: '1')
    @sign1   = Sign.create!(id:1, name: 'テスト符号1', project:@project)
    @sign2   = Sign.create!(id:2, name: 'テスト符号2', project:@project)

    @message = Message.new(name: 'テストメッセージ', project:@project, bytesize:1,canid:1)

  end

  test "should be valid" do
    assert @message.valid?
  end

  test "message layout should not be overlap" do
    msg = Message.new(name: 'テストメッセージ', project:@project, bytesize:1,canid:1)
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

  test "(bit_offset + bit_size) should be less than or equal to message.bytesize" do
    @message.bytesize = 2
    @message.save

    c1 = @message.com_signals.build(
      name: "c1",
      message: @message,
      bit_size: 16,
      bit_offset: 7,
      sign: @sign1
      )

    assert @message.valid?
    assert c1.valid?

    @message.bytesize = 1

    assert @message.invalid?
  end

end
