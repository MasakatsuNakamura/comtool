class Mode < ApplicationRecord
  belongs_to :project

  after_initialize :set_default, if: :new_record?

  validates :title,
            presence: true,
            uniqueness: { case_sensitive: false, scope: :project_id },
            length: { maximum: 50 }

  private

  def set_default
    self.param = <<~"EOF"
      Arbitration:
        rule1:
          DefinitionRef: Rule
          NestedExecutionOnly: false
          RuleInitState: BSWM_UNDEFINED
          RuleExpressionRef: Arbitration/exp1
          RuleTrueActionList: ModeControl/list1
          RuleFalseActionList: ModeControl/list2
        exp1:
          DefinitionRef: LogicalExpression
          LogicalOperator: BSWM_OR
          ArgumentRef:
            - Arbitration/cond1
            - Arbitration/cond2
        cond1:
          DefinitionRef: ModeCondition
          ConditionMode: Arbitration/port1
          ConditionType: BSWM_EQUALS
          ConditionValue:
            BswMode:
              BswRequestedMode: USER_MODE1
        cond2:
          DefinitionRef: ModeCondition
          ConditionMode: Arbitration/port1
          ConditionType: BSWM_EQUALS
          ConditionValue:
            BswMode:
              BswRequestedMode: USER_MODE2
        port1:
          DefinitionRef: ModeRequestPort
          ModeRequestSource:
            BswMModeNotification:
              BswMModeDeclarationGroupPrototypeRef: '?'
          RequestProcessing: BSWM_IMMEDIATE
      ModeControl:
        list1:
          DefinitionRef: ActionList
          ActionListExecution: BSWM_CONDITION
          Items:
            - #0
              DefinitaionRef: ActionListItem
              ActionListItemIndex: 0
              ActionListItemRef: ModeControl/action1
              AbortOnFail: false
        list2:
          DefinitionRef: ActionList
          ActionListExecution: BSWM_CONDITION
          Items:
            - #0
              DefinitaionRef: ActionListItem
              ActionListItemIndex: 0
              ActionListItemRef: ModeControl/action2
              AbortOnFail: false
        action1:
          DefinitionRef: Action
          AvailableActions:
            ComMModeSwitch:
              ComMRequestedMode: BSWM_FULL_COM
              ComMUserRef: '?'
        action2:
          DefinitionRef: Action
          AvailableActions:
            ComMModeSwitch:
              ComMRequestedMode: BSWM_NO_COM
              ComMUserRef: '?'
    EOF
  end
end
