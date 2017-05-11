require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def setup
    @project = Project.create!(id:2, name: 'testProject1', communication_protocol_id: 'can', qines_version_id: 'v1_0')
    @sign1   = Sign.create!(id:2, name: 'testSignal1', project:@project)
    @sign2   = Sign.create!(id:3, name: 'testSignal2', project:@project)

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

    msg.bytesize = 2
    c1.bit_size   = 2
    c1.bit_offset = 7
    c2.bit_size   = 1
    c2.bit_offset = 8

    @project.big_endian!
    assert msg.valid?

    @project.little_endian!
    assert msg.invalid?

    c1.bit_size   = 1
    c1.bit_offset = 7
    c2.bit_size   = 2
    c2.bit_offset = 8

    @project.big_endian!
    assert msg.invalid?

    @project.little_endian!
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

    # Big endian
    @project.big_endian!

    @message.bytesize = 1

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 0
    assert @message.valid?

    @com_signal.bit_size = 8
    @com_signal.bit_offset = 7
    assert @message.valid?

    @com_signal.bit_size = 2
    @com_signal.bit_offset = 0
    assert @message.invalid?

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 8
    assert @message.invalid?

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

    # little endian
    @project.little_endian!

    @message.bytesize = 1

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 7
    assert @message.valid?

    @com_signal.bit_size = 8
    @com_signal.bit_offset = 0
    assert @message.valid?

    @com_signal.bit_size = 2
    @com_signal.bit_offset = 7
    assert @message.invalid?

    @com_signal.bit_size = 1
    @com_signal.bit_offset = 8
    assert @message.invalid?

    @com_signal.bit_size = 9
    @com_signal.bit_offset = 0
    assert @message.invalid?

    @message.bytesize = 2

    @com_signal.bit_size = 16
    @com_signal.bit_offset = 0
    assert @message.valid?

    @com_signal.bit_size = 17
    @com_signal.bit_offset = 0
    assert @message.invalid?

    @message.bytesize = 8

    @com_signal.bit_size = 64
    @com_signal.bit_offset = 0
    assert @message.valid?

    @com_signal.bit_size = 65
    @com_signal.bit_offset = 0
    assert @message.invalid?
  end

  test "name should be unique in project" do
    duplicate_message = @message.dup
    @message.save
    assert_not duplicate_message.valid?

    duplicate_message.name = @message.name.upcase
    assert_not duplicate_message.valid?

    duplicate_message = @message.dup
    project2 = Project.create!(id:3, name: 'testProject2', communication_protocol_id: 'can', qines_version_id: 'v1_0')
    @message.project_id = 3
    @message.save
    assert duplicate_message.valid?
  end

  test "name should be unique from sql" do
    message = Message.new(name: 'testMessageUnique', project:@project, bytesize:1,canid:1)
    message.save

    before_message_count = Message.all.length
    assert_raise(ActiveRecord::RecordNotUnique, "Not find exception") do
      con = ActiveRecord::Base.connection
      con.execute("INSERT INTO messages(name, project_id, created_at, updated_at) VALUES('TESTMESSAGEUNIQUE',2 , 'Fri, 21 Apr 2017 15:40:43 JST +09:00', 'Fri, 21 Apr 2017 15:40:43 JST +09:00')")
    end
    after_message_count = Message.all.length
    assert_equal(before_message_count, after_message_count)
  end

end
