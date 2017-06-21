class Mode < ApplicationRecord
  require 'json'
  require 'yaml'

  belongs_to :project
  #  before_save :trim_image_json , :convert_image_json_to_yaml
  validates :title,
            presence: true,
            uniqueness: { case_sensitive: false, scope: :project_id },
            length: { maximum: 50 },
            format: { with: /\A[a-zA-Z]\w*\z/, message: '半角英数とアンダースコアが利用できます' }

  def trim_image_json
    image = JSON.parse(image_json).map do |obj|
      if obj['type'] == 'ActionListFigure'
        myports = []
        obj['ports'].each do |port|
          next unless port['type'] != 'draw2d.OutputPort'
          myports << port
        end
        obj['ports'] = myports
      end
      obj
    end
    self.image_json = image.to_json
  end

  class Formula
    attr_reader :tree

    def initialize(formula)
      @tree = {
        Rule_1:  {
          DefinitionRef: 'Rule',
          NestedExecutionOnly: false,
          RuleInitState: 'BSWM_UNDEFINED',
          RuleTrueActionList: nil,
          RuleFalseActionList: nil
        }
      }
      @tree[:Rule_1][:RuleExpressionRef] = make_tree(formula)
    end

    def make_tree(formula)
      if !(m = formula.gsub(/OR|AND|\={1,2}|\!\=/).to_a).empty?
        op = m.min do |a, b|
          o = { 'OR' => 1, 'AND' => 2, '=' => 3, '==' => 4, '!=' => 5 }
          o[a] <=> o[b]
        end
        myarr = formula.split(/\s*#{op}\s*/)
        hash_key = key_name(op.match?(/OR|AND/) ? 'Expression' : 'Condition')
        @tree[hash_key] =
          if op.match?(/OR|AND/)
            {
              DefinitionRef: 'LogicalExpression',
              LogicalOperator: "BSWM_#{op}",
              ArgumentRef: myarr.map { |item| make_tree(item) }
            }
          else
            {
              DefinitionRef: 'ModeCondition',
              ConditionMode: myarr[0],
              ConditionType: "BSWM_#{op == '!=' ? 'NOT_' : ''}EQUALS",
              ConditionValue: {
                BswMode: {
                  BswRequestedMode: make_tree(myarr[1])
                }
              }
            }
          end
      else
        hash_key = key_name('Port')
        @tree[hash_key] = {
          DefinitionRef: 'ModeRequestPort',
          ModeRequestSource: {
            BswMModeNotification: {
              BswMModeDeclarationGroupPrototypeRef: formula
            }
          },
          RequestProcessing: 'BSWM_IMMEDIATE'
        }
      end
      hash_key
    end

    def key_name(key)
      key + '_' +
        (@tree.keys.sum do |k|
          k.match?(/^#{key}/) ? 1 : 0
        end + 1).to_s
    end
  end

  # ハッシュのキーがシンボルの場合、文字列に変換する
  def with_str_keys(json)
    json.map do |key, value|
      [key.to_s, value.is_a?(Hash) ? with_str_keys(value) : value]
    end.to_h
  end

  def nodes(json)
    json.reject { |o| o['type'] == 'draw2d.Connection' }
  end

  def children(json, node_id)
    mynode = json.select { |p| p['id'] == node_id }
    return nil if mynode.length.zero?
    mynode = mynode[0]
    mychildren = json.select { |obj| obj['type'] == 'draw2d.Connection' }.select do |o|
      o.key?('source') && o['source']['node'] == mynode['id']
    end
    json.select { |p| mychildren.select{ |c| p['id'] == c['target']['node'] }.length.positive? }
  end

  def parent(json, node_id)
    mynode = json.select { |p| p['id'] == node_id }
    return nil if mynode.length.zero?
    mynode = mynode[0]
    myparent = json.select { |obj| obj['type'] == 'draw2d.Connection' }.select do |o|
      o.key?('target') && o['target']['node'] == mynode['id']
    end
    json.select { |p| myparent.select{ |c| p['id'] == c['source']['node'] }.length.positive? }
  end

  def to_y(json, node_id)
    mynode = json.select { |p| p['id'] == node_id }
    return nil if mynode.length.zero?
    mynode = mynode[0]
    myyaml = []
    if mynode['type'] == 'RuleFigure'
      myyaml << mynode['name'] + '(' + mynode['expr'] + ')'
    else
      myyaml << mynode['name'] + '(' + mynode['entities'].map { |e| e['text'] }.join(' ') + ')'
    end
    children(mynode['id']).each do |node|
      myyaml << node['id']
    end
    myyaml.join("\n")
  end

  def top_node(json)
    nodes(json).select do |n|
      children(n['id']) && parent(n['id'])
    end[0]
  end

  def convert_image_json_to_yaml
    json = JSON.parse(image_json)
    idhash = {}
    json.each do |node|
      next if node['type'] == 'draw2d.Connection'
      i = idhash.values.select { |key| key =~ /#{node['type']}/ }.length + 1
      idhash[node['id']] = node['type'] + '_' + i.to_s
    end
    arbitration = {}
    mode_control = {}
    json.each do |node|
      if node['type'] == 'RuleFigure'
        formula = Formula.new(node['expr'].gsub(/[\[\]]/, ''))
        formula.tree.each { |k, v| arbitration[k] = v }
      elsif node['type'] == 'ActionListFigure'
        mode_control[idhash[node['id']].gsub(/Figure/, '')] = {
          DefinitionRef: 'BswMActionList',
          BswMActionListExecution: 'BSWM_TRIGGER',
          BswMActionListItem: {
            BswMAbortOnFail: 0,
            BswMActionListItemIndex: 0,
            BswMQActionListItemChoice: 'BSWM_ACTION_TYPE',
            BswMActionListItemRef:
              children(json, node['id']).map { |n| idhash[n['id']] }
          }
        }
      elsif node['type'] == 'ActionFigure'
        mode_control[idhash[node['id']].gsub(/Figure/, '')] = {
          BswMAction: {
            BswMAvailableActions: {
              node['name'] => ''
            }
          }
        }
      end
    end
    bswm = {
      BswM: {
        BswMConfig: {
          BswMPartitionRef: '/Ecuc/EcuC/EcucPartitionCollection/EcucPartition',
          BswMArbitration: arbitration,
          BswMModeControl: mode_control
        }
      }
    }
    self.param = with_str_keys(bswm).to_yaml
  end
end
