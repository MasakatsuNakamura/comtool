class ArxmlManager < Hash
  require 'yaml'
  require 'rexml/document'
  require 'rexml/formatters/pretty'
  require 'securerandom'
  include REXML

  # 定数定義
  TOOL_ROOT     = File.expand_path(File.dirname(__FILE__) + '/')
#  VERSION       = '0.0.0'.freeze
#  VER_INFO      = " Generated by Q-Ape Ver. #{VERSION} ".freeze
  VER_INFO      = " Generated by Q-Ape ".freeze
  XML_ROOT_PATH = '/QINeS/'.freeze
  XML_SHORTNAME = 'SHORT-NAME'.freeze
  XML_LONGNAME  = 'LONG-NAME'.freeze
  XML_PARAMVALS = 'PARAMETER-VALUES'.freeze
  XML_REFERVALS = 'REFERENCE-VALUES'.freeze
  XML_SUBCONTAINERS = 'SUB-CONTAINERS'.freeze

  # パラメータデータ型種別格納ハッシュ(これ以外はすべてECUC-NUMERICAL-PARAM-VALUE)
  XML_VALUE_TYPE = { 'ECUC-REFERENCE-DEF'               => 'ECUC-REFERENCE-VALUE',
                     'ECUC-FOREIGN-REFERENCE-DEF'       => 'ECUC-REFERENCE-VALUE',
                     'ECUC-SYMBOLIC-NAME-REFERENCE-DEF' => 'ECUC-REFERENCE-VALUE',
                     'ECUC-INSTANCE-REFERENCE-DEF'      => 'ECUC-INSTANCE-REFERENCE-VALUE',
                     'ECUC-CHOICE-REFERENCE-DEF'        => 'ECUC-REFERENCE-VALUE',
                     'ECUC-ENUMERATION-PARAM-DEF'       => 'ECUC-TEXTUAL-PARAM-VALUE',
                     'ECUC-STRING-PARAM-DEF'            => 'ECUC-TEXTUAL-PARAM-VALUE',
                     'ECUC-MULTILINE-STRING-PARAM-DEF'  => 'ECUC-TEXTUAL-PARAM-VALUE',
                     'ECUC-FUNCTION-NAME-DEF'           => 'ECUC-TEXTUAL-PARAM-VALUE',
                     'ECUC-LINKER-SYMBOL-DEF'           => 'ECUC-TEXTUAL-PARAM-VALUE' }.freeze

  # インスタンス参照型の特別コンテナ
  XML_INSTANCE_REF_CONTAINER = { 'EcucPartitionSoftwareComponentInstanceRef' =>
                                 { 'CONTEXT-ELEMENT-REF' => 'ROOT-SW-COMPOSITION-PROTOTYPE',
                                   'TARGET-REF' => 'SW-COMPONENT-PROTOTYPE' } }.freeze

  def initialize(version: 'r422', kind: 'Ecuc', hash: nil)
    @version = version
    @kind = kind
    hash&.each_pair do |key, value|
      self[key] = value
    end
  end

  def to_arxml
    xsdEdition = @version == 'r422' ? '4-2-2' : '4-0-3'
    xmlEdition = @version == 'r422' ? '4.2.2' : '4.0.3'
    xmlAutosarFixedAttribute = { 'xsi:schemaLocation' => "http://autosar.org/schema/r4.0 autosar_#{xsdEdition}.xsd",
                                 'xmlns'              => 'http://autosar.org/schema/r4.0',
                                 'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance' }

    cXmlInfo = Document.new
    cXmlInfo.add(XMLDecl.new('1.0', 'UTF-8', 'yes'))
    Comment.new(VER_INFO, cXmlInfo)
    cXmlAutosar = cXmlInfo.add_element('AUTOSAR', xmlAutosarFixedAttribute)
    cXmlArPackages = cXmlAutosar.add_element('AR-PACKAGES')

    analysis_ParamInfo

    hImplDataType = delete('IMPLEMENTATION-DATA-TYPE')
    unless hImplDataType.nil?
      cXmlArPackage = cXmlArPackages.add_element('AR-PACKAGE', 'UUID' => SecureRandom.uuid)
      cXmlArPackage.add_element(XML_SHORTNAME).add_text('ImplementationDataTypes')
      cXmlElements = cXmlArPackage.add_element('ELEMENTS')
      hImplDataType.each do |sShortName, hData|
        cXmlEcucModuleConfVal = cXmlElements.add_element('IMPLEMENTATION-DATA-TYPE')
        cXmlEcucModuleConfVal.add_element(XML_SHORTNAME).add_text(sShortName)
        cXmlEcucModuleConfVal.add_element('CATEGORY').add_text(hData['CATEGORY'])
      end
    end

    if @kind == 'Ecuc'
      aModulePaths = []
      each do |sPackageName, hPackageData|
        cXmlArPackage = cXmlArPackages.add_element('AR-PACKAGE', 'UUID' => SecureRandom.uuid)
        cXmlArPackage.add_element(XML_SHORTNAME).add_text(sPackageName)
        cXmlArPackage.add_element(XML_LONGNAME).add_element('L-4', 'L' => 'JA').add_text('')
        cXmlElements = cXmlArPackage.add_element('ELEMENTS')

        hPackageData.each do |sEcucModuleName, hEcucModuleData|
          sRootPath = hEcucModuleData.delete('RootPath')
          if sRootPath.nil?
            sRootPath = XML_ROOT_PATH
          end
          sDefinitionRef = hEcucModuleData.delete('DefinitionRef')
          if sDefinitionRef.nil?
            sDefinitionRef = sEcucModuleName
          end
          aModulePaths.push("/#{sPackageName}/#{sEcucModuleName}")
          cXmlEcucModuleConfVal = cXmlElements.add_element('ECUC-MODULE-CONFIGURATION-VALUES', 'UUID' => SecureRandom.uuid)
          cXmlEcucModuleConfVal.add_element(XML_SHORTNAME).add_text(sEcucModuleName)
          cXmlEcucModuleConfVal.add_element(XML_LONGNAME).add_element('L-4', 'L' => 'JA').add_text('')
          cXmlEcucModuleConfVal.add_element('DEFINITION-REF', 'DEST' => 'ECUC-MODULE-DEF').add_text(sRootPath + sDefinitionRef)
          cXmlEcucModuleConfVal.add_element('ECUC-DEF-EDITION').add_text(xmlEdition)
# TODO: DevToolの出力に合わせるためコメントとする
#          cXmlEcucModuleConfVal.add_element('IMPLEMENTATION-CONFIG-VARIANT').add_text('VARIANT-PRE-COMPILE')
          cXmlContainers = cXmlEcucModuleConfVal.add_element('CONTAINERS')

          hEcucModuleData.each do |sShortName, hParamInfo|
            unless hParamInfo.key?('DefinitionRef')
              hParamInfo['DefinitionRef'] = sShortName
            end

            cContainer = make_container(sShortName, hParamInfo, sRootPath + sDefinitionRef)
            cXmlContainers.add_element(cContainer)
          end
        end
      end
    elsif @kind == 'SystemDesign'
      each do |sPackageName, hPackageData|
        cXmlArPackage = cXmlArPackages.add_element('AR-PACKAGE', {'S' => '', 'UUID' => SecureRandom.uuid})
        cXmlArPackage.add_element(XML_SHORTNAME).add_text(sPackageName)
        cXmlElements = cXmlArPackage.add_element('ELEMENTS')

        hPackageData.each do |sEcucModuleName, hEcucModuleData|
          case sEcucModuleName
          when 'SYSTEM-SIGNAL'
            make_systemsignal(cXmlElements, hEcucModuleData)
          when 'I-SIGNAL-I-PDU'
            make_isignalipdu(cXmlElements, hEcucModuleData)
          end
        end
      end
    end

    output_arxml(document: cXmlInfo)
  end

  private

  def analysis_ParamInfo
    sFileName = "#{TOOL_ROOT}/param_info_#{@version}.yaml"
    hParamInfo = YAML.load_file(sFileName)

    @hForeignRefType = hParamInfo.delete(:FOREIGN_REF_TYPE)
    @aChoiceContainer = hParamInfo.delete(:ECUC_CHOICE_CONTAINER_DEF)
    @aInstanceRefType = hParamInfo['ECUC-INSTANCE-REFERENCE-DEF']

    @hEcuc = {}
    @hDest = {}
    hParamInfo.each do |sType, aParam|
      aParam.each do |sName|
        @hEcuc[sName] = XML_VALUE_TYPE.key?(sType) ? XML_VALUE_TYPE[sType] : 'ECUC-NUMERICAL-PARAM-VALUE'
        @hDest[sName] = sType
      end
    end

    @hReferenceParam = hParamInfo['ECUC-REFERENCE-DEF'] + hParamInfo['ECUC-FOREIGN-REFERENCE-DEF'] + hParamInfo['ECUC-SYMBOLIC-NAME-REFERENCE-DEF'] + hParamInfo['ECUC-INSTANCE-REFERENCE-DEF'] + hParamInfo['ECUC-CHOICE-REFERENCE-DEF']
  end

  def make_container(sShortName, hParamInfo, sPath)
    cContainer = Element.new.add_element('ECUC-CONTAINER-VALUE', 'UUID' => SecureRandom.uuid)
    cContainer.add_element(XML_SHORTNAME).add_text(sShortName)
    cContainer.add_element(XML_LONGNAME).add_element('L-4', 'L' => 'JA').add_text('')

    if @aChoiceContainer.include?(hParamInfo['DefinitionRef'])
      cContainer.add_element('DEFINITION-REF', 'DEST' => 'ECUC-CHOICE-CONTAINER-DEF').add_text("#{sPath}/#{hParamInfo['DefinitionRef']}")
    else
      cContainer.add_element('DEFINITION-REF', 'DEST' => 'ECUC-PARAM-CONF-CONTAINER-DEF').add_text("#{sPath}/#{hParamInfo['DefinitionRef']}")
    end

    hCheck = {}
    if hParamInfo.size != 1
      hCheck[XML_PARAMVALS] = false
      hCheck[XML_REFERVALS] = false
      hCheck[XML_SUBCONTAINERS] = false

      hParamInfo.each do |sParamName, sahValue|
        next if (sParamName == 'DefinitionRef') || sahValue.is_a?(Hash)
        next if @hReferenceParam.include?(sParamName)
        next if !@hEcuc.key?(sParamName) || !@hDest.key?(sParamName)

        if hCheck[XML_PARAMVALS] == false
          cContainer.add_element(XML_PARAMVALS)
          hCheck[XML_PARAMVALS] = true
        end

        aTemp = []
        if sahValue.is_a?(Array)
          aTemp = sahValue
        else
          aTemp.push(sahValue)
        end
        aTemp.each do |sVal|
          cParamContainer_ = Element.new
          cParamContainer = cParamContainer_.add_element(@hEcuc[sParamName])
          cParamContainer.add_element('DEFINITION-REF', 'DEST' => @hDest[sParamName]).add_text("#{sPath}/#{hParamInfo['DefinitionRef']}/#{sParamName}")
          cParamContainer.add_element('VALUE').add_text(sVal.to_s)
          cContainer.elements[XML_PARAMVALS].add_element(cParamContainer)
        end
      end

      hParamInfo.each do |sParamName, sahValue|
        next if (sParamName == 'DefinitionRef') || sahValue.is_a?(Hash)

        if @aInstanceRefType.include?(sParamName)
          next unless sahValue.is_a?(Array)
          next unless XML_INSTANCE_REF_CONTAINER.key?(sParamName)

          if hCheck[XML_REFERVALS] == false
            cContainer.add_element(XML_REFERVALS)
            hCheck[XML_REFERVALS] = true
          end

          aTemp = []
          if sahValue[0].is_a?(Array)
            aTemp = sahValue
          else
            aTemp.push(sahValue)
          end
          aTemp.each do |aVal|
            cParamContainer_ = Element.new
            cParamContainer = cParamContainer_.add_element(@hEcuc[sParamName])
            cParamContainer.add_element('DEFINITION-REF', 'DEST' => @hDest[sParamName]).add_text("#{sPath}/#{hParamInfo['DefinitionRef']}/#{sParamName}")
            cInstanceRef = cParamContainer.add_element('VALUE-IREF')
            aVal.each do |hVal|
              XML_INSTANCE_REF_CONTAINER[sParamName].each do |sParam, sDest|
                if hVal.key?(sParam)
                  cInstanceRef.add_element(sParam, 'DEST' => sDest).add_text(hVal[sParam].to_s)
                end
              end
            end
            cContainer.elements[XML_REFERVALS].add_element(cParamContainer)
          end

        elsif @hReferenceParam.include?(sParamName)
          if hCheck[XML_REFERVALS] == false
            cContainer.add_element(XML_REFERVALS)
            hCheck[XML_REFERVALS] = true
          end

          aTemp = []
          if sahValue.is_a?(Array)
            aTemp = sahValue
          else
            aTemp.push(sahValue)
          end
          aTemp.each do |sVal|
            cParamContainer_ = Element.new
            cParamContainer = cParamContainer_.add_element(@hEcuc[sParamName])
            cParamContainer.add_element('DEFINITION-REF', 'DEST' => @hDest[sParamName]).add_text("#{sPath}/#{hParamInfo['DefinitionRef']}/#{sParamName}")
            if !@hForeignRefType.nil? && @hForeignRefType.key?(sParamName)
              cParamContainer.add_element('VALUE-REF', 'DEST' => @hForeignRefType[sParamName]).add_text(sVal.to_s)
            else
              cParamContainer.add_element('VALUE-REF', 'DEST' => 'ECUC-CONTAINER-VALUE').add_text(sVal.to_s)
            end
            cContainer.elements[XML_REFERVALS].add_element(cParamContainer)
          end
        end
      end

      hParamInfo.each do |sParamName, sahValue|
        next if (sParamName == 'DefinitionRef') || !sahValue.is_a?(Hash)

        if hCheck[XML_SUBCONTAINERS] == false
          cContainer.add_element(XML_SUBCONTAINERS)
          hCheck[XML_SUBCONTAINERS] = true
        end

        unless sahValue.key?('DefinitionRef')
          sahValue['DefinitionRef'] = sParamName
        end

        cContainer.elements[XML_SUBCONTAINERS].add_element(make_container(sParamName, sahValue, "#{sPath}/#{hParamInfo['DefinitionRef']}"))
      end
    end

    cContainer
  end

  def make_systemsignal(cXmlElements, hEcucModuleData)
    hEcucModuleData.each do |sShortName, hSystemSignal|
      cSystemSignal = Element.new.add_element('SYSTEM-SIGNAL', 'UUID' => SecureRandom.uuid)
      cSystemSignal.add_element(XML_SHORTNAME).add_text(sShortName)
      cXmlElements.add_element(cSystemSignal)

      cISignal = Element.new.add_element('I-SIGNAL', 'UUID' => SecureRandom.uuid)
      cISignal.add_element(XML_SHORTNAME).add_text(hSystemSignal['I-SIGNAL'])
      cISignal.add_element('SYSTEM-SIGNAL-REF', 'DEST' => 'SYSTEM-SIGNAL').add_text(hSystemSignal['SYSTEM-SIGNAL-REF'])
      cXmlElements.add_element(cISignal)
    end
  end

  def make_isignalipdu(cXmlElements, hEcucModuleData)
    hEcucModuleData.each do |sShortName, hISignalToIPduMappings|
      cISignalIPdu = Element.new.add_element('I-SIGNAL-I-PDU', 'UUID' => SecureRandom.uuid)
      cISignalIPdu.add_element(XML_SHORTNAME).add_text(sShortName)
      cISignalToIPduMappings = cISignalIPdu.add_element('I-SIGNAL-TO-I-PDU-MAPPINGS')
      hISignalToIPduMappings.each do |hISignalToIPduMapping|
        cISignalToIPduMapping = cISignalToIPduMappings.add_element('I-SIGNAL-TO-I-PDU-MAPPING', 'UUID' => SecureRandom.uuid)
        cISignalToIPduMapping.add_element(XML_SHORTNAME).add_text(hISignalToIPduMapping['I-SIGNAL-TO-I-PDU-MAPPING'])
        cISignalToIPduMapping.add_element('I-SIGNAL-REF', 'DEST' => 'I-SIGNAL').add_text(hISignalToIPduMapping['I-SIGNAL-REF'])
      end
      cXmlElements.add_element(cISignalIPdu)
    end
  end

  def output_arxml(document: nil)
    formatter = Formatters::Pretty.new(4)
    formatter.compact = true
    formatter.width = 500

    sXmlCode = ''
    formatter.write(document, sXmlCode) unless document.nil?

    # XML宣言の属性のコーテーションをダブルに出来ない(?)ため，ここで置換する
    sXmlCode.tr!("'", '"')

    sXmlCode
  end
end
