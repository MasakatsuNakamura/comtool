require 'optparse'
require 'yaml'
require 'rexml/document.rb'
include REXML

TARGET_MODULE = %w[Com PduR CanIf EcuC BswM].freeze

def MakeParamInfo_STMD(sFileName)
  abort("Argument error !! [#{sFileName}]") unless File.exist?(sFileName)

  version = File.dirname(sFileName).split('\\')[-1].split('.').join
  sParamFileName = File.dirname(sFileName) + "/param_info_stmd_r#{version}.yaml"

  MakeParamInfo_file(sFileName)

  hResultSort = {}
  @hResult.each do |sType, aParam|
    hResultSort[sType] = aParam.uniq.sort
  end

  hResultSort[:FOREIGN_REF_TYPE] = @hForeignRefType unless @hForeignRefType.empty?
  hResultSort[:ECUC_CHOICE_CONTAINER_DEF] = @aChoiceContainer unless @aChoiceContainer.empty?

  # RteSoftwareComponentInstanceRefは外部参照とインスタンス参照の
  # 両方に含まれるが，外部参照として扱う
  hResultSort['ECUC-INSTANCE-REFERENCE-DEF'].delete('RteSoftwareComponentInstanceRef')

  open(sParamFileName, 'w') do |io|
    YAML.dump(hResultSort, io)
  end

  puts("Generated #{sParamFileName}")
end

def MakeParamInfo_VSMD(sDirName)
  abort("Argument error !! [#{sDirName}]") unless Dir.exist?(sDirName)

  version = sDirName.split('\\')[-2].split('.').join
  sParamFileName = '.\\' + sDirName.split('\\')[-2] + "/param_info_vsmd_r#{version}.yaml"

  sDirName = File.expand_path(File.dirname(__FILE__) + "/#{sDirName}/*.arxml")
  hResult = {}
  hRefChoiceResult = {}

  Dir.glob(sDirName.to_s).each do |path|
    MakeParamInfo_file(path)

    @hResult.each do |sType, aParam|
      next if aParam.nil?
      hResult[sType] = [] if hResult[sType].nil?
      hResult[sType].concat(aParam)
    end

    hRefChoiceResult[:FOREIGN_REF_TYPE] = {} if hRefChoiceResult[:FOREIGN_REF_TYPE].nil?
    hRefChoiceResult[:FOREIGN_REF_TYPE].merge!(@hForeignRefType) unless @hForeignRefType.empty?

    hRefChoiceResult[:ECUC_CHOICE_CONTAINER_DEF] = [] if hRefChoiceResult[:ECUC_CHOICE_CONTAINER_DEF].nil?
    hRefChoiceResult[:ECUC_CHOICE_CONTAINER_DEF].concat(@aChoiceContainer) unless @aChoiceContainer.empty?
  end

  # RteSoftwareComponentInstanceRefは外部参照とインスタンス参照の
  # 両方に含まれるが，外部参照として扱う
  hResult['ECUC-INSTANCE-REFERENCE-DEF'].delete('RteSoftwareComponentInstanceRef')

  hResultSort = {}
  hResult.each do |sType, aParam|
    hResultSort[sType] = aParam.uniq.sort
  end

  hResultSort[:FOREIGN_REF_TYPE] = hRefChoiceResult[:FOREIGN_REF_TYPE]
  hResultSort[:ECUC_CHOICE_CONTAINER_DEF] = hRefChoiceResult[:ECUC_CHOICE_CONTAINER_DEF]

  open(sParamFileName, 'w') do |io|
    YAML.dump(hResultSort, io)
  end

  puts("Generated #{sParamFileName}")
end

def MakeParamInfo_file(sFileName)
  cXmlData = Document.new(open(sFileName))

  @hResult = {}
  @hResult['ECUC-REFERENCE-DEF'] = []
  @hForeignRefType = {}
  @aChoiceContainer = []

  cXmlData.elements.each('//ECUC-MODULE-DEF') do |cElement1|
    next unless TARGET_MODULE.include?(cElement1.elements['SHORT-NAME'].text)
    cElement1.elements.each('CONTAINERS/ECUC-PARAM-CONF-CONTAINER-DEF') do |cElement2|
      MakeParamInfo_parse_parameter(cElement2)
    end
  end
end

def MakeParamInfo_parse_sub_container(cElement)
  cElement.elements.each do |cElementC|
    if cElementC.name == 'ECUC-CHOICE-CONTAINER-DEF'
      @aChoiceContainer.push(cElementC.elements['SHORT-NAME'].text)
      MakeParamInfo_parse_sub_container(cElementC)
    elsif cElementC.name == 'ECUC-PARAM-CONF-CONTAINER-DEF'
      MakeParamInfo_parse_parameter(cElementC)
    else
      MakeParamInfo_parse_sub_container(cElementC)
    end
  end
end

def MakeParamInfo_parse_parameter(cElement)
  cElement.elements.each('PARAMETERS') do |cElementC|
    cElementC.elements.each do |cElementG|
      @hResult[cElementG.name] = [] unless @hResult.key?(cElementG.name)
      @hResult[cElementG.name].push(cElementG.elements['SHORT-NAME'].text)
    end
  end

  cElement.elements.each('REFERENCES/ECUC-REFERENCE-DEF') do |cElementC|
    @hResult['ECUC-REFERENCE-DEF'].push(cElementC.elements['SHORT-NAME'].text)
  end

  cElement.elements.each('REFERENCES/ECUC-FOREIGN-REFERENCE-DEF') do |cElementC|
    unless @hResult.key?('ECUC-FOREIGN-REFERENCE-DEF')
      @hResult['ECUC-FOREIGN-REFERENCE-DEF'] = []
    end
    @hResult['ECUC-FOREIGN-REFERENCE-DEF'].push(cElementC.elements['SHORT-NAME'].text)
    @hForeignRefType[cElementC.elements['SHORT-NAME'].text] = cElementC.elements['DESTINATION-TYPE'].text
  end

  cElement.elements.each('REFERENCES/ECUC-CHOICE-REFERENCE-DEF') do |cElementC|
    unless @hResult.key?('ECUC-CHOICE-REFERENCE-DEF')
      @hResult['ECUC-CHOICE-REFERENCE-DEF'] = []
    end
    @hResult['ECUC-CHOICE-REFERENCE-DEF'].push(cElementC.elements['SHORT-NAME'].text)
  end

  cElement.elements.each('REFERENCES/ECUC-SYMBOLIC-NAME-REFERENCE-DEF') do |cElementC|
    unless @hResult.key?('ECUC-SYMBOLIC-NAME-REFERENCE-DEF')
      @hResult['ECUC-SYMBOLIC-NAME-REFERENCE-DEF'] = []
    end
    @hResult['ECUC-SYMBOLIC-NAME-REFERENCE-DEF'].push(cElementC.elements['SHORT-NAME'].text)
  end

  cElement.elements.each('REFERENCES/ECUC-INSTANCE-REFERENCE-DEF') do |cElementC|
    unless @hResult.key?('ECUC-INSTANCE-REFERENCE-DEF')
      @hResult['ECUC-INSTANCE-REFERENCE-DEF'] = []
    end
    @hResult['ECUC-INSTANCE-REFERENCE-DEF'].push(cElementC.elements['SHORT-NAME'].text)
  end

  cElement.elements.each('SUB-CONTAINERS') do |cElementC|
    MakeParamInfo_parse_sub_container(cElementC)
  end
end

lMode = nil
cOpt = OptionParser.new
sOptData = nil
cOpt.on('-p XML_FILE', "Generate 'param_info_stmd_{Version}.yaml' from AUTOSAR Ecu Configuration Parameters file") do |xVal|
  sOptData = xVal
  lMode = :MakeParamInfo_STMD
end
cOpt.on('-d VSMD_DIR', "Generate 'param_info_vsmd_{Version}.yaml' from AUTOSAR VSMD Directory") do |xVal|
  sOptData = xVal
  lMode = :MakeParamInfo_VSMD
end

begin
  cOpt.parse(ARGV)
rescue OptionParser::ParseError
  puts(cOpt.help)
  exit(1)
end

if sOptData.nil?
  puts(cOpt.help)
  exit(1)
end

case lMode
when :MakeParamInfo_STMD
  MakeParamInfo_STMD(sOptData)
when :MakeParamInfo_VSMD
  MakeParamInfo_VSMD(sOptData)
end
