require 'test_helper'
require 'diff/lcs'

class DbcfileimportExportTest < ActionDispatch::IntegrationTest
  TXRX_TX = '0'
  TXRX_RX = '1'

  include MessagesHelper

  def setup
  end

  def setup_standard
    # create project for import.
    prj = Project.create!(name: 'Standard_Test', communication_protocol_id: 'can', qines_version_id: 'v2_0', byte_order: 'little_endian')
    prj.save

    # メッセージ設定
    msg = []

    m  = Message.create!(name: 'ExampleMessage0', canid:0, project:prj, bytesize:7)
    m.com_signals.build(name: 'Signal_bool',    project: prj, message: m, bit_offset: 0,  bit_size: 1,  data_type: 'boolean', unit: 'deg/K', description: '0 9 _ _name_ 0name ! # $ % & \' ( ) = ~ | \ [ ] @ * + < > ? ; : - * + ^ { }')
    m.com_signals.build(name: 'Signal_uint_2',  project: prj, message: m, bit_offset: 1,  bit_size: 2,  data_type: 'uint8',   unit: 'm')
    m.com_signals.build(name: 'Signal_uint_8',  project: prj, message: m, bit_offset: 3,  bit_size: 8,  data_type: 'uint8',   unit: '-')
    m.com_signals.build(name: 'Signal_uint_9',  project: prj, message: m, bit_offset: 11, bit_size: 9,  data_type: 'uint16',  unit: '-', description: 'Description Signal_uint_9')
    m.com_signals.build(name: 'Signal_uint_16', project: prj, message: m, bit_offset: 20, bit_size: 16, data_type: 'uint16',  unit: '-', description: 'Description Signal_uint_16')
    m.com_signals.build(name: 'Signal_uint_17', project: prj, message: m, bit_offset: 36, bit_size: 17, data_type: 'uint32',  unit: '-')
    msg << m
    assert m.save

    m  = Message.create!(name: 'ExampleMessage1', canid:1, project:prj, bytesize:4)
    m.com_signals.build(name: 'Signal_uint_32', project: prj, message: m, bit_offset: 0, bit_size: 32, data_type: 'uint32',  unit: '-', description:'Description Test 1')
    msg << m
    assert m.save

    m  = Message.create!(name: 'ExampleMessage2', canid:2, project:prj, bytesize:5)
    m.com_signals.build(name: 'Signal_uint_33', project: prj, message: m, bit_offset: 0, bit_size: 33, data_type: 'uint64',  unit: '-')
    msg << m
    assert m.save

    m  = Message.create!(name: 'ExampleMessage3', canid:3, project:prj, bytesize:8)
    m.com_signals.build(name: 'Signal_uint_64', project: prj, message: m, bit_offset: 0, bit_size: 64, data_type: 'uint64',  unit: '-')
    msg << m
    assert m.save


    m  = Message.create!(name: 'ExampleMessage4', canid:4, project:prj, bytesize:7)
    m.com_signals.build(name: 'Signal_sint_1',  project: prj, message: m, bit_offset: 0,  bit_size: 1,  data_type: 'sint8', unit: 'deg/K')
    m.com_signals.build(name: 'Signal_sint_2',  project: prj, message: m, bit_offset: 1,  bit_size: 2,  data_type: 'sint8',   unit: 'm')
    m.com_signals.build(name: 'Signal_sint_8',  project: prj, message: m, bit_offset: 3,  bit_size: 8,  data_type: 'sint8',   unit: '-')
    m.com_signals.build(name: 'Signal_sint_9',  project: prj, message: m, bit_offset: 11, bit_size: 9,  data_type: 'sint16',  unit: '-')
    m.com_signals.build(name: 'Signal_sint_16', project: prj, message: m, bit_offset: 20, bit_size: 16, data_type: 'sint16',  unit: '-')
    m.com_signals.build(name: 'Signal_sint_17', project: prj, message: m, bit_offset: 36, bit_size: 17, data_type: 'sint32',  unit: '-')
    msg << m
    assert m.save

    m  = Message.create!(name: 'ExampleMessage6', canid:6, project:prj, bytesize:5)
    m.com_signals.build(name: 'Signal_sint_33', project: prj, message: m, bit_offset: 0, bit_size: 33, data_type: 'sint64',  unit: '-')
    msg << m
    assert m.save

    m  = Message.create!(name: 'ExampleMessage5', canid:5, project:prj, bytesize:4)
    m.com_signals.build(name: 'Signal_sint_32', project: prj, message: m, bit_offset: 0, bit_size: 32, data_type: 'sint32',  unit: '-')
    msg << m
    assert m.save

    m  = Message.create!(name: 'ExampleMessage2047', canid:2047, project:prj, bytesize:8)
    m.com_signals.build(name: 'Signal_sint_64', project: prj, message: m, bit_offset: 0, bit_size: 64, data_type: 'sint64',  unit: '-', description:'Description Test 1023')
    msg << m
    assert m.save

    prj
  end

  def setup_exframe
    # create project for import.
    prj = Project.create!(name: 'Exframe_Test', communication_protocol_id: 'can', qines_version_id: 'v2_0', byte_order: 'big_endian')
    prj.save

    # メッセージ設定
    msg = []

    m  = Message.create!(name: 'ExampleMessage0', canid:0, project:prj, bytesize:1)
    m.com_signals.build(name: 'Signal_bool',    project: prj, message: m, bit_offset: 7,  bit_size: 1,  data_type: 'boolean', unit: 'deg/K', description: 'Description Test 0')
    msg << m
    assert m.save

    m  = Message.create!(name: 'ExampleMessage536870911', canid:536870911, project:prj, bytesize:4)
    m.com_signals.build(name: 'Signal_uint_32', project: prj, message: m, bit_offset: 7, bit_size: 32, data_type: 'uint32',  unit: '-', description:'Description Test 536870911')
    msg << m
    assert m.save

    prj
  end

  def compare_file(expected, actual, result_path)
    # compare
    diffs = Diff::LCS.diff(expected.split("\n"),actual.split("\n"))

    # delete old files
    diff_file   = result_path+'.diff.txt'
    actual_file = result_path+'.actual'
    [diff_file, actual_file].each {|f| File.delete(f) if FileTest.exist?(f)}

    # dump results unless diffs empty
    unless diffs.empty? then
      File.open(diff_file, 'w') do |f|
        diffs.each do |diff|
          f.puts '------'
          diff.each { |data| f.puts(data.inspect) }
        end
      end
      IO.write(result_path, expected) unless FileTest.exist?(result_path) # parse_testの場合、比較元ファイルがないので出力する
      IO.write(actual_file, actual)
    end
    assert diffs.empty?, "Compare failed. output actual file to #{actual_file}"
  end

  def ignore_diff(obj)
    obj.id         = nil # ignore diff
    obj.created_at = nil # ignore diff
    obj.updated_at = nil # ignore diff
  end

  def messages_inspect(messages)
    str = ''
    messages.each do |m|
      ignore_diff(m)
      m.project_id = nil # ignore diff
      str += m.inspect + "\n"

      ComSignal.where(message_id:m.id).each do |s|
        ignore_diff(s)
        s.message_id = nil # ignore diff
        str += s.inspect + "\n"
      end
    end
    str
  end

  def parse_test (name, endian)
    actual_prj   = Project.create!(name: name, communication_protocol_id: 'can', qines_version_id: 'v2_0', byte_order: endian)
    expected_prj = ""
    eval("expected_prj  = setup_#{name}")

    dbc_path = "test/integration/dbcs/#{actual_prj.name}.dbc"
    dbc_file = IO.read(dbc_path)
    actual_messages = DbcFileParser.parse(actual_prj, dbc_file)
    actual_messages.each {|m| assert m.save, m.errors.inspect}

    expected_msg = Message.where(project_id:expected_prj.id)

    result_path = dbc_path + '.import'
    [result_path].each {|f| File.delete(f) if FileTest.exist?(f)}

    compare_file(messages_inspect(expected_msg), messages_inspect(actual_messages), result_path)
  end

  def generate_test (name)
    actual_prj = ""
    eval("actual_prj  = setup_#{name}")
    actual_file = DbcFileGenerator.generate(actual_prj)

    result_path = "test/integration/dbcs/#{name}.dbc"
    expected_file = IO.read(result_path)

    compare_file(expected_file, actual_file, result_path)
  end

  test 'Import process should parse messages and com_signals' do
    parse_test('standard', 'little_endian')
  end

  test 'Import process should parse exframe' do
    parse_test('exframe', 'big_endian')
  end


  test 'Export process should generate messages and com_signals' do
    generate_test('standard')
  end


  test 'Export process should generate exframe' do
    generate_test('exframe')
  end

end
