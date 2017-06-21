require 'json'
require 'yaml'

class Formula
  attr_reader :tree

  def initialize(formula)
    @tree = {
      Arbitration: {
        rule1:  {
          DefinitionRef: 'Rule',
          NestedExecutionOnly: false,
          RuleInitState: 'BSWM_UNDEFINED',
          RuleTrueActionList: nil,
          RuleFalseActionList: nil
        }
      }
    }
    @tree[:Arbitration][:rule1][:RuleExpressionRef] = make_tree(formula)
  end

  def make_tree(formula)
    if !(m = formula.gsub(/OR|AND|\=\=|\!\=/).to_a).empty?
      op = m.min do |a, b|
        o = { 'OR' => 1, 'AND' => 2, '==' => 3, '!=' => 4 }
        o[a] <=> o[b]
      end
      myarr = formula.split(/\s*#{op}\s*/)
      hash_key = key_name(op.match?(/OR|AND/) ? 'exp' : 'cond')
      @tree[:Arbitration][hash_key] =
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
      hash_key = key_name('port')
      @tree[:Arbitration][hash_key] = {
        DefinitionRef: 'ModeRequestPort',
        ModeRequestSource: {
          BswMModeNotification: {
            BswMModeDeclarationGroupPrototypeRef: formula
          }
        },
        RequestProcessing: 'BSWM_IMMEDIATE'
      }
    end
    "Arbitration/#{hash_key}"
  end

  def key_name(key)
    key +
      (@tree[:Arbitration].keys.sum do |k|
        k.match?(/^#{key}/) ? 1 : 0
      end + 1).to_s
  end

  # ハッシュのキーがシンボルの場合、文字列に変換する
  def tree_with_str_keys(tree = @tree)
    tree.map do |key, value|
      [key.to_s, value.is_a?(Hash) ? tree_with_str_keys(value) : value]
    end.to_h
  end
end

formula = Formula.new(ARGV[0])
puts formula.tree_with_str_keys.to_yaml
