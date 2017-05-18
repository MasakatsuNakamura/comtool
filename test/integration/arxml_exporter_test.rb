require 'test_helper'
require 'diff/lcs'
require 'pp'

class ArxmlExporterTest < ActionDispatch::IntegrationTest
  include ArxmlExporter_r403
  include ArxmlExporter_r422

  TXRX_TX = '0'
  TXRX_RX = '1'

  def setup
  end

  def compare_arxml_sub(actual, expected_file)
    # uuid は一致しないので取り除く
    actual = actual.gsub(/ UUID=\".{36}\"/,'')

    expected = IO.read(expected_file)

    # uuid は一致しないので取り除く
    expected = expected.gsub(/ UUID=\".{36}\"/,'')

    # 行毎に比較する
    diffs = Diff::LCS.diff(expected.split("\n"),actual.split("\n"))

    # 比較結果を出力する
    diff_file   = expected_file+'.diff.txt'
    actual_file = expected_file+'.actual.arxml'
    [diff_file, actual_file].each {|f| File.delete(f) if FileTest.exist?(f)}

    unless diffs.empty?
      File.open(diff_file, 'w') do |f|
        diffs.each do |diff|
          f.puts '------'
          diff.each do |data|
            f.puts(data.inspect)
          end
        end
      end
      IO.write(actual_file, actual)
    end
    assert diffs.empty?, "Compare failed. output actual file to #{expected_file+'.actual.arxml'}"
  end

  def compare_arxml_r403
    msg = @messages.dup
    # Ecuc
    actual = export_ecuc_comstack_r403(project:  @project, messages: msg.values)
    expected_file = "test/integration/arxmls/Ecuc.#{@project.name}.arxml"

    compare_arxml_sub(actual, expected_file)

    # SystemDesign
    actual = export_signals_r403(project:  @project, messages: msg.values)
    expected_file = "test/integration/arxmls/SystemDesign.#{@project.name}.arxml"

    compare_arxml_sub(actual, expected_file)
  end

  def compare_arxml_r422
    msg = @messages.dup
    # Ecuc
    actual = export_ecuc_comstack_r422(project:  @project, messages: msg.values)
    expected_file = "test/integration/arxmls/Ecuc.#{@project.name}.arxml"

    compare_arxml_sub(actual, expected_file)

    # SystemDesign
    actual = export_signals_r422(project:  @project, messages: msg.values)
    expected_file = "test/integration/arxmls/SystemDesign.#{@project.name}.arxml"

    compare_arxml_sub(actual, expected_file)
  end

  test 'Export the minimum ecu configuration of CAN with QINeS Version 1.1 ' do
    # arxml出力用プロジェクトの作成
    @project = Project.create!(name: 'PrjMinimumCanV11', communication_protocol_id: 'can', qines_version_id: 'v1_0')
    @project.big_endian!

    # メッセージ設定
    @messages = {}
    @messages[:Rx_can0] = Message.create!(name: 'Rx_can0', canid:768, txrx: TXRX_RX, baudrate:'2', project:@project, bytesize:1)
    @messages[:Tx_can0] = Message.create!(name: 'Tx_can0', canid:256, txrx: TXRX_TX, baudrate:'2', project:@project, bytesize:1)

    @messages.each {|k,v| assert v.valid?, "messages[#{k}] is invalid" }

    # シグナル設定
    message = @messages[:Rx_can0]
    message.com_signals.build(name: 'RxSig_can0_0', project: @project, message: message, unit: '', description: 'テスト用入力値', layout: '', bit_offset: 7, bit_size: 3, initial_value: '0', data_type: 0)

    message = @messages[:Tx_can0]
    message.com_signals.build(name: 'TxSig_can0_0', project: @project, message: message, unit: '', description: 'テスト用出力値', layout: '', bit_offset: 7, bit_size: 2, initial_value: '0', data_type: 0)

    @messages.each {|k,v| assert v.save, "messages[#{k}] is invalid" }

    compare_arxml_r403
  end

  test 'Export the multiple messages and multiple signals ecu configuration of CAN with QINeS Version 1.1 ' do
    # arxml出力用プロジェクトの作成
    @project = Project.create!(name: 'PrjMultipleMessageSingalCanV11', communication_protocol_id: 'can', qines_version_id: 'v1_0')
    @project.big_endian!

    # メッセージ設定
    @messages = {}
    @messages[:TxMessage1]  = Message.create!(name: 'TxMessage1', canid:100, txrx: TXRX_TX, baudrate:'2', project:@project, bytesize:1)
    @messages[:TxMessage2]  = Message.create!(name: 'TxMessage2', canid:200, txrx: TXRX_TX, baudrate:'2', project:@project, bytesize:8)
    @messages[:RxMessage1]  = Message.create!(name: 'RxMessage1', canid:300, txrx: TXRX_RX, baudrate:'2', project:@project, bytesize:1)
    @messages[:RxMessage2]  = Message.create!(name: 'RxMessage2', canid:400, txrx: TXRX_RX, baudrate:'2', project:@project, bytesize:8)

    @messages.each {|k,v| assert v.valid?, "messages[#{k}] is invalid" }

    # シグナル設定
    message = @messages[:TxMessage1]
    message.com_signals.build(name: 'TxSignal1', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 7, bit_size: 8, initial_value: '0', data_type: 1)

    message = @messages[:TxMessage2]
    message.com_signals.build(name: 'TxSignal2', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 7, bit_size: 32, initial_value: '0', data_type: 3)
    message.com_signals.build(name: 'TxSignal3', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 39, bit_size: 32, initial_value: '0', data_type: 3)

    message = @messages[:RxMessage1]
    message.com_signals.build(name: 'RxSignal1', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 7, bit_size: 8, initial_value: '0', data_type: 1)

    message = @messages[:RxMessage2]
    message.com_signals.build(name: 'RxSignal2', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 7, bit_size: 1, initial_value: '0', data_type: 0)
    message.com_signals.build(name: 'RxSignal3', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 6, bit_size: 63, initial_value: '0', data_type: 4)

    @messages.each {|k,v| assert v.save, "messages[#{k}] is invalid" }

    compare_arxml_r403
  end

  test 'Export the little_endian ecu configuration of CAN with QINeS Version 1.1 ' do
    # arxml出力用プロジェクトの作成
    @project = Project.create!(name: 'LittleEndianCanV11', communication_protocol_id: 'can', qines_version_id: 'v1_0', )
    @project.little_endian!

    # メッセージ設定
    @messages = {}
    @messages[:Rx_can0] = Message.create!(name: 'Rx_can0', canid:768, txrx: TXRX_RX, baudrate:'2', project:@project, bytesize:1)
    @messages[:Tx_can0] = Message.create!(name: 'Tx_can0', canid:256, txrx: TXRX_TX, baudrate:'2', project:@project, bytesize:1)

    @messages.each {|k,v| assert v.valid?, "messages[#{k}] is invalid" }

    # シグナル設定
    message = @messages[:Rx_can0]
    message.com_signals.build(name: 'RxSig_can0_0', project: @project, message: message, unit: '', description: 'テスト用入力値', layout: '', bit_offset: 0, bit_size: 3, initial_value: '0', data_type: 0)

    message = @messages[:Tx_can0]
    message.com_signals.build(name: 'TxSig_can0_0', project: @project, message: message, unit: '', description: 'テスト用出力値', layout: '', bit_offset: 0, bit_size: 2, initial_value: '0', data_type: 0)

    @messages.each {|k,v| assert v.save, "messages[#{k}] is invalid" }

    compare_arxml_r403
  end

  test 'Export the minimum ecu configuration of CAN with QINeS Version 2.0 ' do
    # arxml出力用プロジェクトの作成
    @project = Project.create!(name: 'PrjMinimumCanV20', communication_protocol_id: 'can', qines_version_id: 'v2_0')
    @project.big_endian!

    # メッセージ設定
    @messages = {}
    @messages[:Rx_can0] = Message.create!(name: 'Rx_can0', canid:768, txrx: TXRX_RX, baudrate:'2', project:@project, bytesize:1)
    @messages[:Tx_can0] = Message.create!(name: 'Tx_can0', canid:256, txrx: TXRX_TX, baudrate:'2', project:@project, bytesize:1)

    @messages.each {|k,v| assert v.valid?, "messages[#{k}] is invalid" }

    # シグナル設定
    message = @messages[:Rx_can0]
    message.com_signals.build(name: 'RxSig_can0_0', project: @project, message: message, unit: '', description: 'テスト用入力値', layout: '', bit_offset: 7, bit_size: 3, initial_value: '0', data_type: 0)

    message = @messages[:Tx_can0]
    message.com_signals.build(name: 'TxSig_can0_0', project: @project, message: message, unit: '', description: 'テスト用出力値', layout: '', bit_offset: 7, bit_size: 2, initial_value: '0', data_type: 0)

    @messages.each {|k,v| assert v.save, "messages[#{k}] is invalid" }

    compare_arxml_r422
  end

  test 'Export the multiple messages and multiple signals ecu configuration of CAN with QINeS Version 2.0 ' do
    # arxml出力用プロジェクトの作成
    @project = Project.create!(name: 'PrjMultipleMessageSingalCanV20', communication_protocol_id: 'can', qines_version_id: 'v2_0')
    @project.big_endian!

    # メッセージ設定
    @messages = {}
    @messages[:TxMessage1]  = Message.create!(name: 'TxMessage1', canid:100, txrx: TXRX_TX, baudrate:'2', project:@project, bytesize:1)
    @messages[:TxMessage2]  = Message.create!(name: 'TxMessage2', canid:200, txrx: TXRX_TX, baudrate:'2', project:@project, bytesize:8)
    @messages[:RxMessage1]  = Message.create!(name: 'RxMessage1', canid:300, txrx: TXRX_RX, baudrate:'2', project:@project, bytesize:1)
    @messages[:RxMessage2]  = Message.create!(name: 'RxMessage2', canid:400, txrx: TXRX_RX, baudrate:'2', project:@project, bytesize:8)

    @messages.each {|k,v| assert v.valid?, "messages[#{k}] is invalid" }

    # シグナル設定
    message = @messages[:TxMessage1]
    message.com_signals.build(name: 'TxSignal1', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 7, bit_size: 8, initial_value: '0', data_type: 1)

    message = @messages[:TxMessage2]
    message.com_signals.build(name: 'TxSignal2', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 7, bit_size: 32, initial_value: '0', data_type: 3)
    message.com_signals.build(name: 'TxSignal3', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 39, bit_size: 32, initial_value: '0', data_type: 3)

    message = @messages[:RxMessage1]
    message.com_signals.build(name: 'RxSignal1', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 7, bit_size: 8, initial_value: '0', data_type: 1)

    message = @messages[:RxMessage2]
    message.com_signals.build(name: 'RxSignal2', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 7, bit_size: 1, initial_value: '0', data_type: 0)
    message.com_signals.build(name: 'RxSignal3', project: @project, message: message, unit: '', description: '', layout: '', bit_offset: 6, bit_size: 63, initial_value: '0', data_type: 4)

    @messages.each {|k,v| assert v.save, "messages[#{k}] is invalid" }

    compare_arxml_r422
  end

  test 'Export the little_endian ecu configuration of CAN with QINeS Version 2.0 ' do
    # arxml出力用プロジェクトの作成
    @project = Project.create!(name: 'LittleEndianCanV20', communication_protocol_id: 'can', qines_version_id: 'v2_0', )
    @project.little_endian!

    # メッセージ設定
    @messages = {}
    @messages[:Rx_can0] = Message.create!(name: 'Rx_can0', canid:768, txrx: TXRX_RX, baudrate:'2', project:@project, bytesize:1)
    @messages[:Tx_can0] = Message.create!(name: 'Tx_can0', canid:256, txrx: TXRX_TX, baudrate:'2', project:@project, bytesize:1)

    @messages.each {|k,v| assert v.valid?, "messages[#{k}] is invalid" }

    # シグナル設定
    message = @messages[:Rx_can0]
    message.com_signals.build(name: 'RxSig_can0_0', project: @project, message: message, unit: '', description: 'テスト用入力値', layout: '', bit_offset: 0, bit_size: 3, initial_value: '0', data_type: 0)

    message = @messages[:Tx_can0]
    message.com_signals.build(name: 'TxSig_can0_0', project: @project, message: message, unit: '', description: 'テスト用出力値', layout: '', bit_offset: 0, bit_size: 2, initial_value: '0', data_type: 0)

    @messages.each {|k,v| assert v.save, "messages[#{k}] is invalid" }

    compare_arxml_r422
  end
end
