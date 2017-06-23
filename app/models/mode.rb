class Mode < ApplicationRecord
  require 'json'
  require 'yaml'
  require 'strscan'

  belongs_to :project
    before_save :convert_image_json_to_yaml
  validates :title,
            presence: true,
            uniqueness: { case_sensitive: false, scope: :project_id },
            length: { maximum: 50 },
            format: { with: /\A[a-zA-Z]\w*\z/, message: '半角英数とアンダースコアが利用できます' }

  def convert_image_json_to_yaml
    image = JSON.parse(image_json)
    @nodes = image['nodes']
    @edges = image['edges']

    @param = {
      Arbitration: {DefinitionRef: 'BswMArbitration'},
      ModeControl: {DefinitionRef: 'BswMModeControl'}
    }

    @obj_counts = Hash.new(0)

    @nodes.each do |node|
      case node['label']
      when /\ARule_/
        set_container(:Arbitration, bswMRule_new(node:node))
      when /\AActionList_/
        set_container(:ModeControl, bswMActionList_new(node:node))
      when /\AAction_/
        set_container(:ModeControl, bswMAction_new(node:node))
      else
        # skip
      end
    end

    self.param = key_to_s(@param).to_yaml
  end

  private

  def matched_captures(fmt, scanner)
    /#{fmt}/.match(scanner.matched).named_captures
  end

  def set_container (dest, container)
    name = container.delete :shortName
    @param[dest][name] = container
    name
  end

  def ref (shortName)
    case shortName
    when nil
      nil
    when /\AActionList_/, /\AAction_/
      'ModeControl/' + shortName
    else
      'Arbitration/' + shortName
    end
  end

  def set_LogicalExpression_containers(scanner: nil)
    grammer = {}
    grammer[:operator] = /\s*(?:(?<BswMLogicalOperator>AND|NAND|OR|XOR)\s*\(\s*){1,1}?/
    grammer[:condition] = /
      \s*(?:(?<BswMModeRequestSource>BswMBswModeNotification|BswMCanSMIcomIndication|BswMCanSMIndication|
      BswMComMIndication|BswMComMInitiateReset|BswMComMPncRequest|BswMDcmComModeRequest|BswMEcuMIndication|
      BswMEcuMRUNRequestIndication|BswMEcuMWakeupSource|BswMEthSMIndication|BswMFrSMIndication|BswMGenericRequest|
      BswMJ1939DcmBroadcastStatus|BswMJ1939NmIndication|BswMLinSMIndication|BswMLinScheduleIndication|BswMLinTpModeRequest|
      BswMModeSwitchErrorEvent|BswMNmIfCarWakeUpIndication|BswMNvMJobModeIndication|BswMNvMRequest|BswMPartitionRestarted|
      BswMSdClientServiceCurrentState|BswMSdConsumedEventGroupCurrentState|BswMSdEventHandlerCurrentState|BswMSwcModeNotification|
      BswMSwcModeRequest|BswMWdgMRequestPartitionReset)
      \s*\(\.\.\.\)\s*(?<BswMConditionType>==|!=)\s*(?<BswMBswRequestedMode>[\w:]+)\s*,*\s*){1,1}?
    /x

    rule_expression = nil
    logexps = []
    s = scanner
    until s.eos?
      if s.scan(grammer[:operator])
        cap = matched_captures(grammer[:operator], s)
        logexps << bswMLogicalExpression_new(cap)
      elsif s.scan(grammer[:condition])
        cap = matched_captures(grammer[:condition], s)
        shortName = set_container(:Arbitration, bswMModeCondition_new(cap))

        logexps << bswMLogicalExpression_new({'BswMLogicalOperator' => 'NO_OPE'}) if logexps.empty?
        logexps[-1][:BswMArgumentRef] = [] if logexps[-1][:BswMArgumentRef].nil?
        logexps[-1][:BswMArgumentRef] << ref(shortName)

        rule_expression = logexps[0][:shortName] if logexps.length == 1
      elsif s.scan(/\s*\).*\R*/)
        shortName = set_container(:Arbitration, logexps.pop)
        unless logexps.empty?
          logexps[-1][:BswMArgumentRef] = [] if logexps[-1][:BswMArgumentRef].nil?
          logexps[-1][:BswMArgumentRef] << ref(shortName)
        end
      elsif s.scan(/.*\R*/)
      else
        raise "scanner error"
      end
    end

    set_container(:Arbitration, logexps.pop) unless logexps.empty?

    rule_expression
  end

  def connected_node(from: nil, to: nil, edges_label: nil)
    edges = @edges.select do |e|
      bool = e['label'] == edges_label
      bool &= e['from'] == from unless from.nil?
      bool &= e['to'] == to unless to.nil?
      bool
    end
    unless edges.empty?
      @nodes.select{|n| n['id'] == edges[0]['to']}.first
    else
      nil
    end
  end

  def get_ActionItemList_containers(parent_id:nil)
    @obj_counts['BswMActionListItem'] = 0
    containers = []

    id = parent_id

    while (node = connected_node(from:id))
      action = connected_node(from:node['id'], edges_label:'Do')
      containers << bswMActionListItem_new({BswMActionListItemRef: action['label']})
      id = node['id']
    end

    containers
  end

  def post_new(obj)
    obj.delete_if {|k,v| v.nil?}
    @obj_counts[obj[:DefinitionRef]] += 1
    obj
  end

  def bswMRule_new (node:nil)
    logexp_name = set_LogicalExpression_containers(scanner: StringScanner.new(node['title']))
    nested_node = connected_node(to:  node['id'], edges_label: 'Do')
    true_node   = connected_node(from: node['id'], edges_label: 'True')
    false_node  = connected_node(from: node['id'], edges_label: 'False')

    obj = {}
    obj[:shortName] = node['label']
    obj[:DefinitionRef] = 'BswMRule'
    obj[:BswMRuleInitState] = 'BSWM_FALSE'
    obj[:BswMNestedExecutionOnly] = !nested_node.nil?
    obj[:BswMRuleExpressionRef]   = ref(logexp_name)
    obj[:BswMRuleTrueActionList]  = ref(true_node['label']) unless true_node.nil?
    obj[:BswMRuleFalseActionList] = ref(false_node['label']) unless false_node.nil?

    post_new obj
  end

  def bswMActionList_new (node:nil)
    containers = get_ActionItemList_containers(parent_id: node['id'])

    obj = {}
    obj[:shortName] = node['label']
    obj[:DefinitionRef] = 'BswMActionList'
    containers.each { |c| name = c.delete :shortName; obj[name] = c }

    post_new obj
  end

  def item_choice (shortName)
    case shortName
    when /\ARule_/
      'BSWM_RULE_TYPE'
    when /\AActionList_/
      'BSWM_ACTION_LIST_TYPE'
    when /\AAction_/
      'BSWM_ACTION_TYPE'
    else
      nil
    end
  end

  def bswMActionListItem_new (param)
    obj = {}
    obj[:DefinitionRef] = 'BswMActionListItem'
    obj[:shortName] = "item_#{@obj_counts[obj[:DefinitionRef]]}"
    obj[:BswMQActionListItemChoice] = item_choice(param[:BswMActionListItemRef])
    obj[:BswMActionListItemIndex] = @obj_counts[obj[:DefinitionRef]]
    obj[:BswMActionListItemRef] = ref(param[:BswMActionListItemRef])
    obj[:BswMAbortOnFail] = 'false'

    post_new obj
  end

  def bswMAction_new (node:nil)
    begin
      param = YAML.load node['title']
    rescue
      param = nil
    end

    obj = {}
    obj[:shortName] = node['label']
    obj[:DefinitionRef] = 'BswMAction'
    obj[:BswMAvailableActions] = param['BswMAvailableActions']

    post_new obj
  end

  def bswMModeCondition_new (param)
    port_name = set_container(:Arbitration, bswMModeRequestPort_new(param))

    condition_type = {'==' => 'BSWM_EQUALS', '!=' => 'BSWM_EQUALS_NOT'}

    obj = {}
    obj[:DefinitionRef] = 'BswMModeCondition'
    obj[:shortName] = "cond_#{@obj_counts[obj[:DefinitionRef]]}"
    obj[:BswMConditionMode] = ref port_name
    obj[:BswMConditionType] = condition_type[param['BswMConditionType']]
    obj[:BswMConditionValue] = {BswMBswMode: {BswMBswRequestedMode: param['BswMBswRequestedMode']}}

    post_new obj
  end

  def bswMLogicalExpression_new (param)
    obj = {}
    obj[:DefinitionRef] = 'BswMLogicalExpression'
    obj[:shortName] = "exp_#{@obj_counts[obj[:DefinitionRef]]}"
    obj[:BswMLogicalOperator] = 'BSWM_' + param['BswMLogicalOperator']

    post_new obj
  end

  def bswMModeRequestPort_new (param)
    obj = {}
    obj[:DefinitionRef] = 'BswMModeRequestPort'
    obj[:shortName] = "port_#{@obj_counts[obj[:DefinitionRef]]}"
    obj[:BswMModeRequestSource] = {param['BswMModeRequestSource'] => nil}

    post_new obj
  end

  def key_to_s (obj)
    obj.inject({}) do |returned_hash, (key, value)|
      value = key_to_s(value) if value.is_a? Hash
      returned_hash[key.to_s] = value;
      returned_hash
    end
  end

end
