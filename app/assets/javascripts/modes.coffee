# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
class Draw

  constructor: (doc) ->
    @doc = doc
    @elements = []
    @arrows = []

  draw: (obj) ->
    if typeof(obj) == 'string' || obj instanceof String
      keys = obj.match(/^([^\/]*)\/(.*)$/)
      obj = @doc[keys[1]][keys[2]]
    if obj['DefinitionRef'] == 'Rule'
      @elements.push {
        id: @elements.length + 1,
        shape: 'box',
        font: {align: 'left'},
        color: {background:'pink', border:'purple'}
      }
      myelement = @elements[@elements.length - 1]
      myelement.label = @draw(obj['RuleExpressionRef'])
      if obj['RuleTrueActionList']
        chidld_node = @draw(obj['RuleTrueActionList'])
        @arrows.push {from: myelement.id, to: chidld_node.id, arrows: 'to', label: 'true'}
      if obj['RuleFalseActionList']
        chidld_node = @draw(obj['RuleFalseActionList'])
        @arrows.push {from: myelement.id, to:  chidld_node.id, arrows: 'to', label: 'false'}
      return myelement
    else if obj['DefinitionRef'] == 'LogicalExpression'
      operator = obj['LogicalOperator']
      operator = operator.replace(/^BSWM_/, '')
      operator = ' ' + operator + ' '
      return (('(' + @draw(cond) + ')') for cond in obj['ArgumentRef']).join(operator + '\n')
    else if obj['DefinitionRef'] == 'ModeCondition'
      operator = obj['ConditionType']
      operator = ' == ' if operator == 'BSWM_EQUALS'
      operator = ' != ' if operator == 'BSWM_NOT_EQUALS'
      return obj['ConditionValue']['BswMode']['BswRequestedMode'] + operator + @draw(obj['ConditionMode'])
    else if obj['DefinitionRef'] == 'ModeRequestPort'
      return obj['ModeRequestSource']['BswMModeNotification']['BswMModeDeclarationGroupPrototypeRef']
    else if obj['DefinitionRef'] == 'ActionList'
      last_id = null
      nodes = []
      for action in obj['Items']
        nodes.push @draw(action['ActionListItemRef'])
        if nodes.length > 1
          @arrows.push {from: nodes[nodes.length - 2].id, to: nodes[nodes.length - 1].id, arrows: 'to'}
      return nodes[0]
    else if obj['DefinitionRef'] == 'Action'
      @elements.push {
        id: @elements.length + 1,
        label: jsyaml.dump(obj['AvailableActions'])[...-1],
        shape: 'box',
        font: {align: 'left'},
        color: {background:'moccasin', border:'orange'}
      }
      return @elements[@elements.length - 1]

@preview = ->
  editor = ace.edit("ace-editor")
  $('#param').val(editor.getValue())
  doc = null
  try
    doc = jsyaml.load($('#param').val())
  catch e
    doc = { 'Error': ['Yaml format error'] }

  draw = new Draw(doc)
  draw.draw(doc['Arbitration']['rule1'])

  # create an array with nodes
  nodes = new vis.DataSet(draw.elements)

  # create an array with edges
  edges = new vis.DataSet(draw.arrows)

  # create a network
  container = document.getElementById('mynetwork')
  data = { nodes: nodes, edges: edges }
  options = {}
  network = new vis.Network(container, data, options)
