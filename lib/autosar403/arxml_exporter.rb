require 'securerandom'

module ArxmlExporter
  def export_ecuc_comstack(project:nil, messages:nil)
    @project = project
    @messages = messages
    @longname = LongName.new(l4:'JA')

    autosar = Autosar.new()
    autosar.arpackages = Hash.new([])
    autosar.arpackages[:Ecuc] = ArPackage.new(shortname:'Ecuc', longname:@longname)
    autosar.arpackages[:Ecuc] .elements = Hash.new([])
    autosar.arpackages[:Ecuc] .elements[:CanIf] = create_CanIf()
    autosar.arpackages[:Ecuc] .elements[:Com] = create_Com()
    autosar.arpackages[:Ecuc] .elements[:Ecuc] = create_Ecuc()
    autosar.arpackages[:Ecuc] .elements[:PduR] = create_PduR()

#    pp autosar
    return autosar.to_arxml()
  end

  def export_signals(project:nil, messages:nil)
    @project = project
    @messages = messages

    autosar = Autosar.new()
    autosar.arpackages = Hash.new([])
    autosar.arpackages[:SystemDesign] = ArPackage.new(shortname:'SystemDesign')
    autosar.arpackages[:SystemDesign].elements = Hash.new([])
    create_SystemSignal(autosar.arpackages[:SystemDesign].elements)
    autosar.arpackages[:SystemDesign].elements[:ISignalIPdu] = create_ISignalIPdu()

    return autosar.to_arxml(kind:'SystemDesign')
  end

  private
  def create_CanIf
    # CanIf モジュール作成
    canIf = EcucModuleConfigurationValue.new(shortname:"CanIf_#{@project.name}", longname:@longname,
                                                                    definitionref:DefinitionRef.new(value:'/QINeS/CanIf'), uuid:SecureRandom.uuid.upcase,
                                                                    containers:Hash.new([]))
    # CanIfInitCfg コンテナ作成
    canIfInitCfg = EcucContainerValue.new(shortname:"CanIfInitCfg_#{@project.name}", longname:@longname,
                            definitionref:DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/QINeS/CanIf/CanIfInitCfg'),
                            uuid:SecureRandom.uuid.upcase, subcontainers:Hash.new([]))

    count_CanIfTxPduCfg = 0
    count_CanIfRxPduCfg = 0
    @messages.each { |message|
      if message.txrx == 0 then # 送信
        shortname = "CanIfTxPduCfg_" + message.name
        definitionref = DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg')
        # PARAMETER-VALUES 作成
        parametervalues = Hash.new([])
        parametervalues[:CanIfTxPduCanId] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduCanId'),
                      value:sprintf("0x%08x", message.canid))
        parametervalues[:CanIfTxPduId] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduId'),
                      value:count_CanIfTxPduCfg.to_s)
        parametervalues[:CanIfTxPduType] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduType'),
                      value:'STATIC')
        parametervalues[:CanIfTxPduDlc] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduDlc'),
                      value:message.bytesize.to_s)
        parametervalues[:CanIfTxPduCanIdType] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduCanIdType'),
                      value:'STANDARD_CAN') # TODO 設定可能にしたい
        parametervalues[:CanIfTxPduPnFilterPdu] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-BOOLEAN-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduPnFilterPdu'),
                      value:0.to_s)
        parametervalues[:CanIfTxPduReadNotifyStatus] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-BOOLEAN-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduReadNotifyStatus'),
                      value:0.to_s)
        parametervalues[:CanIfTxPduUserTxConfirmationUL] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduUserTxConfirmationUL'),
                      value:"PDUR")
        # REFERENCE-VALUES 作成
        referencevalues = Hash.new([])
#        referencevalues[:CanIfTxPduBswSchExclAreaIdRef] = ReferenceValue.new(
#                      definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduBswSchExclAreaIdRef'),
#                      valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE', value:'/Ecuc/Rte/CanIf/CriticalSection'))
#        referencevalues[:CanIfTxPduBufferRef] = ReferenceValue.new(
#                      definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduBufferRef'),
#                      valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE', value:"/Ecuc/CanIf_#{@project.name}/CanIfInitCfg_#{@project.name}/BufCfg0"))
        referencevalues[:CanIfTxPduRef] = ReferenceValue.new(
                      definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfTxPduCfg/CanIfTxPduRef'),
                      valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE', value:"/Ecuc/Ecuc_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"))

        # CanIfTxPduCfg コンテナ作成
        canIfInitCfg.subcontainers[":#{shortname}"] = EcucContainerValue.new(shortname:shortname, longname:@longname, definitionref:definitionref,
                                                                                parametervalues:parametervalues,  referencevalues:referencevalues, uuid:SecureRandom.uuid.upcase)
        count_CanIfTxPduCfg += 1
      elsif message.txrx == 1 then  # 受信
        shortname = "CanIfRxPduCfg_" + message.name
        definitionref = DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg')
        # PARAMETER-VALUES 作成
        parametervalues = Hash.new([])
        parametervalues[:CanIfRxPduCanId] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg/CanIfRxPduCanId'),
                      value:sprintf("0x%08x", message.canid))
        parametervalues[:CanIfRxPduDlc] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg/CanIfRxPduDlc'),
                      value:message.bytesize.to_s)
        parametervalues[:CanIfRxPduCanIdType] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg/CanIfRxPduCanIdType'),
                      value:'STANDARD_CAN') # TODO 設定可能にしたい
        parametervalues[:CanIfRxPduId] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg/CanIfRxPduId'),
                      value:count_CanIfRxPduCfg.to_s)
        parametervalues[:CanIfRxPduReadData] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-BOOLEAN-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg/CanIfRxPduReadData'),
                      value:0.to_s)
        parametervalues[:CanIfRxPduReadNotifyStatus] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-BOOLEAN-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg/CanIfRxPduReadNotifyStatus'),
                      value:0.to_s)
        parametervalues[:CanIfRxPduUserRxIndicationUL] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg/CanIfRxPduUserRxIndicationUL'),
                      value:"PDUR")
        # REFERENCE-VALUES 作成
        referencevalues = Hash.new([])
#        referencevalues[:CanIfRxPduBswSchExclAreaIdRef] = ReferenceValue.new(
#                      definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg/CanIfRxPduBswSchExclAreaIdRef'),
#                      valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE', value:'/Ecuc/Rte/CanIf/CriticalSection'))
#        referencevalues[:CanIfRxPduHrhIdRef] = ReferenceValue.new(
#                      definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg/CanIfRxPduHrhIdRef'),
#                      valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE', value:"/Ecuc/CanIf_#{@project.name}/CanIfInitCfg_#{@project.name}/InitHohCfg0/CanIfHrhCfg_can0"))
        referencevalues[:CanIfRxPduRef] = ReferenceValue.new(
                      definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/QINeS/CanIf/CanIfInitCfg/CanIfRxPduCfg/CanIfRxPduRef'),
                      valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE', value:"/Ecuc/Ecuc_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"))

        # CanIfRxPduCfg コンテナ作成
        canIfInitCfg.subcontainers[":#{shortname}"] = EcucContainerValue.new(shortname:shortname, longname:@longname, definitionref:definitionref,
                                                                                parametervalues:parametervalues,  referencevalues:referencevalues, uuid:SecureRandom.uuid.upcase)
        count_CanIfRxPduCfg += 1
      end
    }

    canIf.containers[:CanIfInitCfg] = canIfInitCfg
    return canIf
  end

  def create_Com
    # Com モジュール作成
    com = EcucModuleConfigurationValue.new(shortname:"Com_#{@project.name}", longname:@longname,
                                                                    definitionref:DefinitionRef.new(value:'/eSOL/EcucDefs/Com'), uuid:SecureRandom.uuid.upcase,
                                                                    containers:Hash.new([]))
    # ComConfig コンテナ作成
    # PARAMETER-VALUES 作成
    parametervalues = {}
    parametervalues[:ComConfigurationId] = ParameterValue.new(type:"ECUC-NUMERICAL-PARAM-VALUE",
                  definitionref:DefinitionRef.new(dest:"ECUC-INTEGER-PARAM-DEF", value:"/eSOL/EcucDefs/Com/ComConfig/ComConfigurationId"),
                  value:"0")
    comConfig = EcucContainerValue.new(shortname:"ComConfig_#{@project.name}", longname:@longname,
                            definitionref:DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/eSOL/EcucDefs/Com/ComConfig'),
                            parametervalues:parametervalues,
                            uuid:SecureRandom.uuid.upcase, subcontainers:Hash.new([]))

    # ComIPdu コンテナ作成
    count_ComIPduHandleId = 0
    @messages.each { |message|
      if message.txrx == 0 then # 送信
        shortname = "ComIPdu_" + message.name
        definitionref = DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu')
        # PARAMETER-VALUES 作成
        parametervalues = Hash.new([])
        parametervalues[:ComIPduCancellationSupport] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-BOOLEAN-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduCancellationSupport'),
                      value:0.to_s)
        parametervalues[:ComIPduDirection] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduDirection'),
                      value:'SEND')
        parametervalues[:ComIPduHandleId] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduHandleId'),
                      value:count_ComIPduHandleId.to_s)
        parametervalues[:ComIPduSignalProcessing] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduSignalProcessing'),
                      value:'IMMEDIATE')
        parametervalues[:ComIPduType] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduType'),
                      value:'NORMAL')
        # REFERENCE-VALUES 作成
        referencevalues = Hash.new([])
#        referencevalues[:ComIPduGroupRef] = ReferenceValue.new(
#                      definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduGroupRef'),
#                      valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE', value:"/Ecuc/Com_#{@project.name}/ComConfig_#{@project.name}/IPduGrp_can0"))
        message.com_signals.each { |signal|
          referencevalues["ComIPduSignalRef#{signal.name}".to_sym] = ReferenceValue.new(
                        definitionref:DefinitionRef.new(dest:"ECUC-REFERENCE-DEF", value:"/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduSignalRef"),
                        valueref:ValueRef.new(dest:"ECUC-CONTAINER-VALUE", value:"/Ecuc/Com_#{@project.name}/ComConfig_#{@project.name}/" + 'ComSignal_' + signal.name))
        }
        referencevalues[:ComPduIdRef] = ReferenceValue.new(
                      definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComPduIdRef'),
                      valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE', value:"/Ecuc/Ecuc_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"))

        # ComIPdu コンテナ作成
        txComIPdu = EcucContainerValue.new(shortname:shortname, longname:@longname, definitionref:definitionref, parametervalues:parametervalues,
                                                            referencevalues:referencevalues, uuid:SecureRandom.uuid.upcase, subcontainers:Hash.new([]))

        txComIPdu.subcontainers[:ComTxIPdu] = create_ComTxIPdu(message)

        comConfig.subcontainers[":#{shortname}"] = txComIPdu
        count_ComIPduHandleId += 1
      elsif message.txrx == 1 then  # 受信
        shortname = "ComIPdu_" + message.name
        definitionref = DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu')
        # PARAMETER-VALUES 作成
        parametervalues = Hash.new([])
        parametervalues[:ComIPduCancellationSupport] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-BOOLEAN-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduCancellationSupport'),
                      value:0.to_s)
        parametervalues[:ComIPduDirection] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduDirection'),
                      value:'RECEIVE')
        parametervalues[:ComIPduHandleId] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduHandleId'),
                      value:count_ComIPduHandleId.to_s)
        parametervalues[:ComIPduSignalProcessing] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduSignalProcessing'),
                      value:'IMMEDIATE')
        parametervalues[:ComIPduType] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduType'),
                      value:'NORMAL')
        # REFERENCE-VALUES 作成
        referencevalues = Hash.new([])
#        referencevalues[:ComIPduGroupRef] = ReferenceValue.new(
#                      definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduGroupRef'),
#                      valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE', value:"/Ecuc/Com_#{@project.name}/ComConfig_#{@project.name}/IPduGrp_can0"))
        message.com_signals.each { |signal|
          referencevalues["ComIPduSignalRef#{signal.name}".to_sym] = ReferenceValue.new(
                        definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComIPduSignalRef'),
                        valueref:ValueRef.new(dest:"ECUC-CONTAINER-VALUE", value:"/Ecuc/Com_#{@project.name}/ComConfig_#{@project.name}/" + 'ComSignal_' + signal.name))
        }
        referencevalues[:ComPduIdRef] = ReferenceValue.new(
                      definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComPduIdRef'),
                      valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE', value:"/Ecuc/Ecuc_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"))

        # ComIPdu コンテナ作成
        comConfig.subcontainers[":#{shortname}"] = EcucContainerValue.new(shortname:shortname, longname:@longname, definitionref:definitionref,
                                                                                parametervalues:parametervalues,  referencevalues:referencevalues, uuid:SecureRandom.uuid.upcase)
        count_ComIPduHandleId += 1
      end
    }

    # ComSignal コンテナ作成
    count_ComHandleId = 0
    @messages.each_with_index { |message, index|
        message.com_signals.each { |signal|
          shortname = 'ComSignal_' + signal.name
          definitionref = DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComSignal')
          # PARAMETER-VALUES 作成
          parametervalues = Hash.new([])
          parametervalues[:ComBitPosition] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                        definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComSignal/ComBitPosition'),
                        value:signal.bit_offset.to_s)
          parametervalues[:ComBitSize] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                        definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComSignal/ComBitSize'),
                        value:signal.bit_size.to_s)
          parametervalues[:ComHandleId] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                        definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComSignal/ComHandleId'),
                        value:count_ComHandleId.to_s)
          parametervalues[:ComSignalEndianness] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                        definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComSignal/ComSignalEndianness'),
                        value:'BIG_ENDIAN')
#          parametervalues[:ComSignalInitValue] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
#                        definitionref:DefinitionRef.new(dest:'ECUC-STRING-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComSignal/ComSignalInitValue'),
#                        value:0.to_s)
          parametervalues[:ComSignalType] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                        definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComSignal/ComSignalType'),
                        value:'UINT8')
          # REFERENCE-VALUES 作成
          referencevalues = Hash.new([])
          referencevalues[:ComPduIdRef] = ReferenceValue.new(
                        definitionref:DefinitionRef.new(dest:'ECUC-FOREIGN-REFERENCE-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComSignal/ComSystemTemplateSystemSignalRef'),
                        valueref:ValueRef.new(dest:'I-SIGNAL-TO-I-PDU-MAPPING', value:"/SystemDesign/ISignalIPdu_#{@project.name}/ISignalToIPduMapping_#{signal.name}_#{message.name}"))

          # ComSignal コンテナ作成
          comConfig.subcontainers[":#{shortname}"] = EcucContainerValue.new(shortname:shortname, longname:@longname, definitionref:definitionref,
                                                                                  parametervalues:parametervalues,  referencevalues:referencevalues, uuid:SecureRandom.uuid.upcase)

          count_ComHandleId += 1
      }
    }

    com.containers[:ComConfig] = comConfig
    return com
  end

  def create_ComTxIPdu(message)
    # ComTxIPdu コンテナ作成
    comTxIPdu = EcucContainerValue.new(shortname:'ComTxIPdu_'+message.name, longname:@longname,
                            definitionref:DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/eSOL/EcucDefs/Com/ComConfig/ComIPdu/ComTxIPdu'),
                            parametervalues:nil, uuid:SecureRandom.uuid.upcase, subcontainers:nil)

    return comTxIPdu
  end

  def create_Ecuc
    # Ecuc モジュール作成
    ecuc = EcucModuleConfigurationValue.new(shortname:"Ecuc_#{@project.name}", longname:@longname,
                                                                    definitionref:DefinitionRef.new(value:'/AUTOSAR/EcucDefs/EcuC'), uuid:SecureRandom.uuid.upcase,
                                                                    containers:Hash.new([]))
    # EcucPduCollection コンテナ作成
    ecucPduCollection = EcucContainerValue.new(shortname:"EcucPduCollection_#{@project.name}", longname:@longname,
                            definitionref:DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/AUTOSAR/EcucDefs/EcuC/EcucPduCollection'),
                            parametervalues:Hash.new([]), uuid:SecureRandom.uuid.upcase, subcontainers:Hash.new([]))
    # PARAMETER-VALUES 作成
    ecucPduCollection.parametervalues[:PduIdTypeEnum] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                        definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/AUTOSAR/EcucDefs/EcuC/EcucPduCollection/PduIdTypeEnum'),
                        value:'UINT8')
    ecucPduCollection.parametervalues[:PduLengthTypeEnum] = ParameterValue.new(type:'ECUC-TEXTUAL-PARAM-VALUE',
                        definitionref:DefinitionRef.new(dest:'ECUC-ENUMERATION-PARAM-DEF', value:'/AUTOSAR/EcucDefs/EcuC/EcucPduCollection/PduLengthTypeEnum'),
                        value:'UINT8')

    @messages.each { |message|
        shortname = "Pdu_#{message.name}"
        definitionref = DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/AUTOSAR/EcucDefs/EcuC/EcucPduCollection/Pdu')
        # PARAMETER-VALUES 作成
        parametervalues = Hash.new([])
        parametervalues[:PduLength] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                      definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF', value:'/AUTOSAR/EcucDefs/EcuC/EcucPduCollection/Pdu/PduLength'),
                      value:message.bytesize.to_s)

        # Pdu コンテナ作成
        ecucPduCollection.subcontainers[":#{shortname}"] = EcucContainerValue.new(shortname:shortname, longname:@longname, definitionref:definitionref,
                                                                                        parametervalues:parametervalues, uuid:SecureRandom.uuid.upcase)
    }

    ecuc.containers[:EcucPduCollection] = ecucPduCollection
    return ecuc
  end

  def create_PduR
    # PduR モジュール作成
    pduR = EcucModuleConfigurationValue.new(shortname:"PduR_#{@project.name}", longname:@longname,
                                                                    definitionref:DefinitionRef.new(value:'/AUTOSAR/EcucDefs/PduR'), uuid:SecureRandom.uuid.upcase,
                                                                    containers:Hash.new([]))
    # PduRRoutingTables コンテナ作成
    # PARAMETER-VALUES 作成
    parametervalues = Hash.new([])
    parametervalues[:PduRConfigurationId] = ParameterValue.new(type:"ECUC-NUMERICAL-PARAM-VALUE",
                  definitionref:DefinitionRef.new(dest:"ECUC-INTEGER-PARAM-DEF", value:"/AUTOSAR/EcucDefs/PduR/PduRRoutingTables/PduRConfigurationId"),
                  value:0.to_s)

    pduRRoutingTables = EcucContainerValue.new(shortname:"PduRRoutingTables_#{@project.name}", longname:@longname,
                            definitionref:DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF', value:'/AUTOSAR/EcucDefs/PduR/PduRRoutingTables'),
                            parametervalues: parametervalues,
                            uuid:SecureRandom.uuid.upcase, subcontainers:Hash.new([]))

    # PduRRoutingTable コンテナ作成
    pduRRoutingTable = EcucContainerValue.new(shortname:"PduRRoutingTable_#{@project.name}", longname:@longname,
                            definitionref:DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF',
                                                                  value:'/AUTOSAR/EcucDefs/PduR/PduRRoutingTables/PduRRoutingTable'),
                            uuid:SecureRandom.uuid.upcase, subcontainers:Hash.new([]))
    pduRRoutingTables.subcontainers[:PduRRoutingTable] = pduRRoutingTable

    @messages.each_with_index { |message, index|
      # PduRRoutingPath コンテナ作成
      shortname = "PduRRoutingPath_#{message.name}"
      definitionref = DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF',
                                              value:'/AUTOSAR/EcucDefs/PduR/PduRRoutingTables/PduRRoutingTable/PduRRoutingPath')
      pduRRoutingPath = EcucContainerValue.new(shortname:shortname, longname:@longname, definitionref:definitionref,
                                                                                        uuid:SecureRandom.uuid.upcase, subcontainers:Hash.new([]))
      pduRRoutingTable.subcontainers[":#{shortname}"] = pduRRoutingPath

      # PduRDestPdu コンテナ作成
      shortname = "PduRDestPdu_#{message.name}"
      definitionref = DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF',
                                                value:'/AUTOSAR/EcucDefs/PduR/PduRRoutingTables/PduRRoutingTable/PduRRoutingPath/PduRDestPdu')
      # PARAMETER-VALUES 作成
      parametervalues = Hash.new([])
      parametervalues[:PduRDestPduHandleId] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                    definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF',
                        value:'/AUTOSAR/EcucDefs/PduR/PduRRoutingTables/PduRRoutingTable/PduRRoutingPath/PduRDestPdu/PduRDestPduHandleId'),
                    value:index.to_s)
      # REFERENCE-VALUES 作成
      referencevalues = Hash.new([])
      referencevalues[:PduRDestPduRef] = ReferenceValue.new(
                    definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF',
                            value:'/AUTOSAR/EcucDefs/PduR/PduRRoutingTables/PduRRoutingTable/PduRRoutingPath/PduRDestPdu/PduRDestPduRef'),
                    valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE',
                                value:"/Ecuc/Ecuc_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"))
      pduRDestPdu = EcucContainerValue.new(shortname:shortname, longname:@longname, definitionref:definitionref,
                                                parametervalues: parametervalues, referencevalues:referencevalues, uuid:SecureRandom.uuid.upcase)
      pduRRoutingPath.subcontainers[":#{shortname}"] = pduRDestPdu

      # PduRSrcPdu コンテナ作成
      shortname = "PduRSrcPdu_#{message.name}"
      definitionref = DefinitionRef.new(dest:'ECUC-PARAM-CONF-CONTAINER-DEF',
                                                value:'/AUTOSAR/EcucDefs/PduR/PduRRoutingTables/PduRRoutingTable/PduRRoutingPath/PduRSrcPdu')
      # PARAMETER-VALUES 作成
      parametervalues = Hash.new([])
      parametervalues[:PduRSourcePduHandleId] = ParameterValue.new(type:'ECUC-NUMERICAL-PARAM-VALUE',
                    definitionref:DefinitionRef.new(dest:'ECUC-INTEGER-PARAM-DEF',
                        value:'/AUTOSAR/EcucDefs/PduR/PduRRoutingTables/PduRRoutingTable/PduRRoutingPath/PduRSrcPdu/PduRSourcePduHandleId'),
                    value:index.to_s)
      # REFERENCE-VALUES 作成
      referencevalues = Hash.new([])
      referencevalues[:PduRDestPduRef] = ReferenceValue.new(
                    definitionref:DefinitionRef.new(dest:'ECUC-REFERENCE-DEF',
                            value:'/AUTOSAR/EcucDefs/PduR/PduRRoutingTables/PduRRoutingTable/PduRRoutingPath/PduRSrcPdu/PduRSrcPduRef'),
                    valueref:ValueRef.new(dest:'ECUC-CONTAINER-VALUE',
                                value:"/Ecuc/Ecuc_#{@project.name}/EcucPduCollection_#{@project.name}/Pdu_#{message.name}"))
      pduRSrcPdu = EcucContainerValue.new(shortname:shortname, longname:@longname, definitionref:definitionref,
                                                parametervalues: parametervalues, referencevalues:referencevalues, uuid:SecureRandom.uuid.upcase)
      pduRRoutingPath.subcontainers[":#{shortname}"] = pduRSrcPdu
    }

    pduR.containers[:PduRRoutingTables] = pduRRoutingTables
    return pduR
  end

  def create_SystemSignal(elements)
    @messages.each { |message|
      message.com_signals.each { |signal|
        # SystemSignal 作成
        shortname_systemSignal = "SystemSignal_#{signal.name}"
        systemSignal = SystemSignal.new(shortname:shortname_systemSignal, uuid:SecureRandom.uuid.upcase)
        # ISignal 作成
        shortname_isignal = "ISignal_#{signal.name}"
        systemsignalref =  SystemSignalRef.new(dest:'SYSTEM-SIGNAL', value:"/SystemDesign/#{shortname_systemSignal}")
        iSignal = ISignal.new(shortname:shortname_isignal, systemsignalref:systemsignalref, uuid:SecureRandom.uuid.upcase)

        elements[":#{shortname_systemSignal}"] = systemSignal
        elements[":#{shortname_isignal}"] = iSignal
      }
    }
  end

  def create_ISignalIPdu
    # ISignalIPdu 作成
    iSignalIPdu = ISignalIPdu.new(shortname:"ISignalIPdu_#{@project.name}", uuid:SecureRandom.uuid.upcase, isignaltoipdumappings:Hash.new([]))

    @messages.each { |message|
      message.com_signals.each { |signal|
        shortname = "ISignalToIPduMapping_#{signal.name}_#{message.name}"
        iSignalIPdu.isignaltoipdumappings[":#{shortname}"] = ISignalToIPduMapping.new(shortname:shortname,
                                  isignalref:ISignalRef.new(dest:'I-SIGNAL', value:"/SystemDesign/ISignal_#{signal.name}"), uuid:SecureRandom.uuid.upcase)
      }
    }
    return iSignalIPdu
  end
end
