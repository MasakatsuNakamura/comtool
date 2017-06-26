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
    actual = export_ecuc_comstack_r403(project: @project, messages: msg.values, modes: @modes)
    expected_file = "test/integration/arxmls/Ecuc.#{@project.name}.arxml"

    compare_arxml_sub(actual, expected_file)

    # SystemDesign
    actual = export_signals_r403(project: @project, messages: msg.values)
    expected_file = "test/integration/arxmls/SystemDesign.#{@project.name}.arxml"

    compare_arxml_sub(actual, expected_file)
  end

  def compare_arxml_r422
    msg = @messages.dup
    # Ecuc
    actual = export_ecuc_comstack_r422(project: @project, messages: msg.values, modes: @modes)
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
    @modes = []

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
    @modes = []

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
    @modes = []

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
    @modes = []

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
    @modes = []

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
    @modes = []

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

  BSWM_CONFIG_JSON =
  '{"nodes":[{"id":"1","level":1,"shape":"box","label":"Rule_1","font":{"face":"courier","align":"center"},"color":{"background":"pink","border":"purple"},"title":"BswMNvMJobModeIndication(...) == NVM_REQ_OK"},{"id":"7","level":1,"shape":"box","label":"Rule_7","font":{"face":"courier","align":"left"},"color":{"background":"pink","border":"purple"},"title":"AND(\n  BswMNvMJobModeIndication(...) == NVM_REQ_OK,\n  OR(\n    BswMNvMJobModeIndication(...) == NVM_REQ_NG,\n    BswMEcuMIndication(...) ==  ECUM_STATE_STARTUP_ONE,\n  )\n  BswMEcuMIndication(...) ==  ECUM_STATE_STARTUP_TWO,\n)"},{"id":"8","level":3,"shape":"box","label":"ActionList_8","font":{"face":"courier","align":"left"},"color":{"background":"cyan","border":"blue"}},{"id":"9","label":"1","level":4,"shape":"circle","font":{"face":"courier","align":"left"},"color":{"background":"moccasin","border":"orange"}},{"id":"10","level":7,"shape":"box","label":"Action_10","font":{"face":"courier","align":"left"},"color":{"background":"lightgreen","border":"limegreen"},"title":"BswMRteSwitch"},{"id":"11","level":3,"shape":"box","label":"ActionList_11","font":{"face":"courier","align":"left"},"color":{"background":"cyan","border":"blue"}},{"id":"12","level":3,"shape":"box","label":"ActionList_12","font":{"face":"courier","align":"left"},"color":{"background":"cyan","border":"blue"}},{"id":"13","label":"1","level":4,"shape":"circle","font":{"face":"courier","align":"left"},"color":{"background":"moccasin","border":"orange"}},{"id":"14","label":"2","level":5,"shape":"circle","font":{"face":"courier","align":"left"},"color":{"background":"moccasin","border":"orange"}},{"id":"15","level":7,"shape":"box","label":"Action_15","font":{"face":"courier","align":"left"},"color":{"background":"lightgreen","border":"limegreen"},"title":"BswMComMModeSwitch"},{"id":"16","label":"1","level":4,"shape":"circle","font":{"face":"courier","align":"left"},"color":{"background":"moccasin","border":"orange"}}],"edges":[{"from":"7","to":"8","label":"True","arrows":"to","id":"98366d27-30c4-4034-92d9-cc38b6c60c2b"},{"from":"8","to":"9","id":"0555a9d8-b63c-43be-bfd3-c0aab98405a8"},{"from":"9","to":"10","label":"Do","arrows":"to","id":"c6f56090-37a4-435f-8bb3-47b0d8e34dcc"},{"from":"1","to":"11","label":"True","arrows":"to","id":"697488e7-fcd9-43f6-af04-d2287ff6b25b"},{"from":"1","to":"12","label":"False","arrows":"to","id":"ae757813-2ea8-4720-bcbc-c0cbd6bd3e59"},{"from":"11","to":"13","id":"13a7f5f0-ab52-4ea0-a022-ad62c7b352a7"},{"from":"13","to":"14","id":"41fbf2e5-17b7-44d9-a710-b20780da6a0c"},{"from":"14","to":"15","label":"Do","arrows":"to","id":"f14e2956-6a94-4dd0-b3d7-9051261bb1cc"},{"from":"13","to":"12","label":"Do","arrows":"to","id":"da473a4e-3404-4400-a695-5bd70604cbfa"},{"from":"12","to":"16","id":"852949b9-6b5f-4866-a84b-b9574612089d"},{"from":"16","to":"7","label":"Do","arrows":"to","id":"39fe3eb7-dbb9-4412-833e-fedffc508e6f"}]}'
  test 'Export BswM configuration with QINeS Version 1.1 ' do
    # arxml出力用プロジェクトの作成
    @project = Project.create!(name: 'PrjBswMV11', communication_protocol_id: 'can', qines_version_id: 'v1_0')
    @project.big_endian!
    @modes = []
    @modes[0] = Mode.create!(project:@project, title: 'BswMConfig', image_json: BSWM_CONFIG_JSON)
    @modes[0].save
    @messages = {}

    compare_arxml_r403
  end

  test 'Export BswM configuration with QINeS Version 2.0 ' do
    # arxml出力用プロジェクトの作成
    @project = Project.create!(name: 'PrjBswMV20', communication_protocol_id: 'can', qines_version_id: 'v2_0')
    @project.big_endian!
    @modes = []
    @modes[0] = Mode.create!(project:@project, title: 'BswMConfig', image_json: BSWM_CONFIG_JSON)
    @modes[0].save
    @messages = {}

    compare_arxml_r422
  end
end
