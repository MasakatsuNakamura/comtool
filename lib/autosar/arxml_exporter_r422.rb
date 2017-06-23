require 'yaml'

module ArxmlExporter_r422
  def export_ecuc_comstack_r422(project: nil, messages: nil, modes: nil)
    @project = project
    @messages = messages
    @modes = modes

    cEcucConfig = ArxmlManager.new(version: 'r422', kind: 'Ecuc')
    cEcucConfig['Ecuc'] = {
      "BswM_#{@project.name}" => create_BswM_r422,
      "CanIf_#{@project.name}" => create_CanIf_r422,
      "Com_#{@project.name}" => create_Com_r422,
      "Ecuc_#{@project.name}" => create_Ecuc_r422,
      "PduR_#{@project.name}" => create_PduR_r422
    }

    #    pp cEcucConfig
    cEcucConfig.to_arxml
  end

  def export_signals_r422(project: nil, messages: nil)
    @project = project
    @messages = messages

    cSystemDesign = ArxmlManager.new(version: 'r422', kind: 'SystemDesign')
    cSystemDesign['SystemDesign'] = {
      'SYSTEM-SIGNAL' => create_SystemSignal_r422,
      'I-SIGNAL-I-PDU' => create_ISignalIPdu_r422
    }

    #    pp cSystemDesign
    cSystemDesign.to_arxml
  end

  private

  def create_CanIf_r422
    hCanIfContainers = {}
    hCanIfSubContainers = {}

    count_CanIfTxPduCfg = 0
    count_CanIfRxPduCfg = 0
    @messages.each do |message|
      if message.txrx == 0 # 送信
        hParameter = {}
        hParameter['DefinitionRef']                  = 'CanIfTxPduCfg'
        hParameter['CanIfTxPduCanId']                = sprintf('0x%08x', message.canid)
        hParameter['CanIfTxPduId']                   = count_CanIfTxPduCfg.to_s
        hParameter['CanIfTxPduType']                 = 'STATIC'
        hParameter['CanIfTxPduDlc']                  = message.bytesize.to_s
        hParameter['CanIfTxPduCanIdType']            = message.data_frame.upcase
        hParameter['CanIfTxPduPnFilterPdu']          = 0.to_s
        hParameter['CanIfTxPduReadNotifyStatus']     = 0.to_s
        hParameter['CanIfTxPduUserTxConfirmationUL'] = 'PDUR'
        hParameter['CanIfTxPduRef']                  =
          "/Ecuc/Ecuc_#{@project.name}/EcucConfigSet_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"
        # CanIfTxPduCfg サブコンテナ
        hCanIfSubContainers["CanIfTxPduCfg_#{message.name}"] = hParameter.sort.to_h
        count_CanIfTxPduCfg += 1
      elsif message.txrx == 1 # 受信
        hParameter = {}
        hParameter['DefinitionRef']                 = 'CanIfRxPduCfg'
        hParameter['CanIfRxPduCanId']               = sprintf('0x%08x', message.canid)
        hParameter['CanIfRxPduDlc']                 = message.bytesize.to_s
        hParameter['CanIfRxPduCanIdType']           = message.data_frame.upcase
        hParameter['CanIfRxPduId']                  = count_CanIfRxPduCfg.to_s
        hParameter['CanIfRxPduReadData']            = 0.to_s
        hParameter['CanIfRxPduReadNotifyStatus']    = 0.to_s
        hParameter['CanIfRxPduUserRxIndicationUL']  = 'PDUR'
        hParameter['CanIfRxPduRef']                 =
          "/Ecuc/Ecuc_#{@project.name}/EcucConfigSet_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"
        # CanIfRxPduCfg サブコンテナ
        hCanIfSubContainers["CanIfRxPduCfg_#{message.name}"] = hParameter.sort.to_h
        count_CanIfRxPduCfg += 1
      end
    end
    hParameter = {}
    hParameter['DefinitionRef'] = 'CanIfInitCfg'
    hCanIfSubContainers.merge!(hParameter)

    # CanIfInitCfg コンテナ
    hCanIfContainers["CanIfInitCfg_#{@project.name}"] = hCanIfSubContainers.sort.to_h
    hParameter = {}
    hParameter['DefinitionRef'] = 'CanIf'
    hCanIfContainers.merge!(hParameter)

    # CanIf モジュール
    hCanIfContainers.sort.to_h
  end

  def create_Com_r422
    hComContainers = {}
    hComSubContainers = {}

    @messages.each_with_index do |message, index|
      hParameter = {}
      hParameter['DefinitionRef']               = 'ComIPdu'
      hParameter['ComIPduCancellationSupport']  = 0.to_s
      hParameter['ComIPduHandleId']             = index.to_s
      hParameter['ComIPduSignalProcessing']     = 'COM_Q_IPDU_SIGPRO_IMMEDIATE'
      hParameter['ComIPduType']                 = 'COM_Q_IPDU_TYPE_NORMAL'
      message.com_signals.each do |signal|
        hParameter['ComIPduSignalRef'] =
          "/Ecuc/Com_#{@project.name}/ComConfig_#{@project.name}/ComSignal_#{signal.name}"
      end
      hParameter['ComPduIdRef'] =
        "/Ecuc/Ecuc_#{@project.name}/EcucConfigSet_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"
      if message.txrx == 0 # 送信
        hParameter['ComIPduDirection'] = 'COM_Q_IPDU_DIR_SEND'
        # ComTxIPdu サブコンテナ
        hParameter["ComTxIPdu_#{message.name}"] = create_ComTxIPdu_r422
      elsif message.txrx == 1 # 受信
        hParameter['ComIPduDirection'] = 'COM_Q_IPDU_DIR_RECEIVE'
      end
      # ComIPdu サブコンテナ
      hComSubContainers["ComIPdu_#{message.name}"] = hParameter.sort.to_h
    end

    count_ComHandleId = 0
    @messages.each do |message|
      message.com_signals.each do |signal|
        hParameter = {}
        hParameter['DefinitionRef']       = 'ComSignal'
        hParameter['ComBitPosition']      = signal.bit_offset.to_s
        hParameter['ComBitSize']          = signal.bit_size.to_s
        hParameter['ComHandleId']         = count_ComHandleId.to_s
        hParameter['ComInitialValueOnly'] = 0.to_s
        hParameter['ComSignalEndianness'] = (@project.little_endian? ? 'COM_Q_SIG_ENDIAN_LITTLE_ENDIAN' : 'COM_Q_SIG_ENDIAN_BIG_ENDIAN')
        hParameter['ComSignalInitValue']  = signal.initial_value
        sigtype_value = "COM_Q_SIGTYPE_#{signal.data_type.upcase}"
        sigtype_value.sub!(/COM_Q_SIGTYPE_BOOLEAN/, 'COM_Q_SIGTYPE_BOOL')
        hParameter['ComSignalType'] = sigtype_value
        hParameter['ComSystemTemplateSystemSignalRef'] =
          "/SystemDesign/ISignalIPdu_#{@project.name}/ISignalToIPduMapping_#{signal.name}_#{message.name}"
        # ComSignal サブコンテナ
        hComSubContainers["ComSignal_#{signal.name}"] = hParameter.sort.to_h
        count_ComHandleId += 1
      end
    end
    hParameter = {}
    hParameter['DefinitionRef'] = 'ComConfig'
    hComSubContainers.merge!(hParameter)

    # ComConfig コンテナ
    hComContainers["ComConfig_#{@project.name}"] = hComSubContainers.sort.to_h
    hParameter = {}
    hParameter['DefinitionRef'] = 'Com'
    hComContainers.merge!(hParameter)

    # Com モジュール
    hComContainers.sort.to_h
  end

  def create_ComTxIPdu_r422
    hParameter = {}
    hParameter['DefinitionRef'] = 'ComTxIPdu'

    # ComTxIPdu コンテナ
    hParameter.sort.to_h
  end

  def create_Ecuc_r422
    hEcucContainers = {}
    hEcucSubContainers = {}
    hEcucSubSubContainers = {}

    @messages.each do |message|
      hParameter = {}
      hParameter['DefinitionRef'] = 'Pdu'
      hParameter['PduLength']     = message.bytesize.to_s
      # Pdu サブコンテナ
      hEcucSubSubContainers["Pdu_#{message.name}"] = hParameter.sort.to_h
    end
    hParameter = {}
    hParameter['DefinitionRef'] = 'EcucPduCollection'
    hEcucSubSubContainers.merge!(hParameter)

    # EcucPduCollection サブコンテナ
    hEcucSubContainers["EcucPduCollection_#{@project.name}"] = hEcucSubSubContainers.sort.to_h
    hParameter = {}
    hParameter['DefinitionRef'] = 'EcucConfigSet'
    hEcucSubContainers.merge!(hParameter)

    # EcucConfigSet コンテナ
    hEcucContainers["EcucConfigSet_#{@project.name}"] = hEcucSubContainers.sort.to_h
    hParameter = {}
    hParameter['DefinitionRef'] = 'EcuC'
    hEcucContainers.merge!(hParameter)

    # Ecuc モジュール
    hEcucContainers.sort.to_h
  end

  def create_PduR_r422
    hPduRContainers = {}
    hPduRSubContainers = {}
    hPduRSubSubContainers = {}

    @messages.each_with_index do |message, index|
      # PduRRoutingPath コンテナ
      sPduRRoutingPath = "PduRRoutingPath_#{message.name}"
      hPduRSubSubContainers[sPduRRoutingPath] = {}
      hParameter = {}
      hParameter['DefinitionRef']       = 'PduRDestPdu'
      hParameter['PduRDestPduHandleId'] = index.to_s
      hParameter['PduRDestPduRef'] =
        "/Ecuc/Ecuc_#{@project.name}/EcucConfigSet_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"
      # PduRDestPdu コンテナ
      hPduRSubSubContainers[sPduRRoutingPath]["PduRDestPdu_#{message.name}"] = hParameter.sort.to_h
      hParameter = {}
      hParameter['DefinitionRef']         = 'PduRSrcPdu'
      hParameter['PduRSourcePduHandleId'] = index.to_s
      hParameter['PduRSrcPduRef'] =
        "/Ecuc/Ecuc_#{@project.name}/EcucConfigSet_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"
      # PduRSrcPdu コンテナ
      hPduRSubSubContainers[sPduRRoutingPath]["PduRSrcPdu_#{message.name}"] = hParameter.sort.to_h
      hParameter = {}
      hParameter['DefinitionRef'] = 'PduRRoutingPath'
      hPduRSubSubContainers[sPduRRoutingPath].merge!(hParameter)
    end
    hParameter = {}
    hParameter['DefinitionRef'] = 'PduRRoutingTable'
    hPduRSubSubContainers.merge!(hParameter)

    # PduRRoutingTable コンテナ
    hPduRSubContainers["PduRRoutingTable_#{@project.name}"] = hPduRSubSubContainers.sort.to_h
    hParameter = {}
    hParameter['DefinitionRef']       = 'PduRRoutingTables'
    hParameter['PduRConfigurationId'] = 0.to_s
    hPduRSubContainers.merge!(hParameter)

    # PduRRoutingTables コンテナ
    hPduRContainers["PduRRoutingTables_#{@project.name}"] = hPduRSubContainers.sort.to_h
    hParameter = {}
    hParameter['DefinitionRef'] = 'PduR'
    hPduRContainers.merge!(hParameter)

    # PduR モジュール
    hPduRContainers.sort.to_h
  end

  BSWM_REF = %w[
    BswMConditionMode
    BswMArgumentRef
    BswMRuleExpressionRef
    BswMRuleFalseActionList
    BswMRuleTrueActionList
    BswMActionListItemRef
  ].freeze

  def create_BswM_r422
    hBswMContainers = {}
    hBswMContainers['DefinitionRef'] = 'BswM'

    @modes.each do |mode|
      sBswMConfig = "BswMConfig_#{mode.title}"
      @sBswMConfig_path = "/Ecuc/BswM_#{@project.name}/#{sBswMConfig}/"
      hBswMContainers[sBswMConfig] = {}
      hBswMContainers[sBswMConfig]['DefinitionRef'] = 'BswMConfig'

      hYamlData = YAML.safe_load(mode.param)
      hYamlData.each_key do |sKey|
        hBswMContainers[sBswMConfig][sKey] = create_BswMSubContainers_r422(hYaml: hYamlData[sKey])
      end
      hBswMContainers[sBswMConfig] = hBswMContainers[sBswMConfig].sort.to_h
    end

    hBswMContainers.sort.to_h
  end

  def create_BswMSubContainers_r422(hYaml: nil)
    hSubContainers = {}
    hSubContainers['DefinitionRef'] = hYaml.delete('DefinitionRef')
    hYaml.each_key do |sKey|
      hSubContainers[sKey] = create_BswMParameters_r422(sKey: sKey, hParamInfo: hYaml[sKey])
    end
    hSubContainers.sort.to_h
  end

  def create_BswMParameters_r422(sKey: '', hParamInfo: nil)
    hParameters = {}
    sDefinitionRef = hParamInfo.delete('DefinitionRef')
    sDefinitionRef = sKey if sDefinitionRef.nil?
    hParameters['DefinitionRef'] = sDefinitionRef
    hParamInfo.each do |sParamName, sahValue|
      if sahValue.is_a?(Hash)
        hParameters[sParamName] = create_BswMParameters_r422(sKey: sParamName, hParamInfo: sahValue)
      else
        if BSWM_REF.include?(sParamName)
          if sahValue.is_a?(Array)
            aTemp = []
            sahValue.each do |sVal|
              aTemp.push("#{@sBswMConfig_path}#{sVal}")
            end
            sahValue = aTemp
          else
            sahValue = "#{@sBswMConfig_path}#{sahValue}"
          end
        end
        hParameters[sParamName] = sahValue
      end
    end
    hParameters.sort.to_h
  end

  def create_SystemSignal_r422
    hSystemSignal = {}
    @messages.each do |message|
      message.com_signals.each do |signal|
        shortname_systemSignal = "SystemSignal_#{signal.name}"
        hParameter = {}
        hParameter['I-SIGNAL']          = "ISignal_#{signal.name}"
        hParameter['SYSTEM-SIGNAL-REF'] = "/SystemDesign/#{shortname_systemSignal}"
        hSystemSignal[shortname_systemSignal.to_s] = hParameter
      end
    end
    hSystemSignal.sort.to_h
  end

  def create_ISignalIPdu_r422
    hISignalIPdu = {}
    aContents = []
    @messages.each do |message|
      message.com_signals.each do |signal|
        hParameter = {}
        hParameter['I-SIGNAL-TO-I-PDU-MAPPING'] = "ISignalToIPduMapping_#{signal.name}_#{message.name}"
        hParameter['I-SIGNAL-REF']              = "/SystemDesign/ISignal_#{signal.name}"
        aContents << hParameter
      end
    end
    hISignalIPdu["ISignalIPdu_#{@project.name}"] = aContents
    hISignalIPdu.sort.to_h
  end
end
