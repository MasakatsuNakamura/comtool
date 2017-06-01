# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(window).load ->
  image_json = $('#image_json').val()

  try
    myjson = JSON.parse(image_json)
    raise 'Error' if !myjson.nodes || myjson.nodes.length == 0
    nodes = new vis.DataSet(myjson.nodes)
  catch e
    nodes = new vis.DataSet([{
      id: '1',
      level: 1,
      shape: 'box',
      label: 'Rule_1',
      font: { face: 'courier', align: 'center' },
      color: {background:'pink', border:'purple'}
    }])

  # create an array with edges
  try
    myjson = JSON.parse(image_json)
    raise 'Error' if !myjson.edges || myjson.edges.length == 0
    edges = new vis.DataSet(myjson.edges)
  catch e
    edges = new vis.DataSet([])

  # create a network
  container = document.getElementById('mynetwork')
  data = { nodes: nodes, edges: edges }
  options = {
    edges: {
      smooth: {
        type: 'cubicBezier',
        forceDirection: 'vertical', # or 'horizontal'
        roundness: 0.8
      }
    },
    layout: {
      hierarchical: {
        enabled: true,
        levelSeparation: 40,
        nodeSpacing: 130,
        direction: 'UD',
        sortMethod: 'directed'
      }
    },
    # interaction: {
    #   dragNodes :false
    # },
    physics: {
      enabled: false
    }
  }
  network = new vis.Network(container, data, options)

  update_listbox = ->
    $('#node-to-add > option').remove()
    $('#node-to-add').append($('<option>').html('Select a node to add...').val('0'))
    mylabel = nodes.get($('#node_id').val()).label
    if mylabel.match(/^[1-9][0-9]*$/)
      $('#node-to-add').append($('<option>').html('New Action').val('Action'))
      $('#node-to-add').append($('<option>').html('New ActionList').val('ActionList'))
      $('#node-to-add').append($('<option>').html('New Rule').val('Rule'))
      nodes.forEach (node) ->
        unless node.label.match(/^[1-9][0-9]*$/)
          if mylabel.match(/^[1-9][0-9]*$/)
            $('#node-to-add').append($('<option>').html(node.label).val(node.id))
    else if mylabel.match(/^Rule_/)
      $('#node-to-add').append($('<option>').html('True Action List').val('TrueActionList'))
      $('#node-to-add').append($('<option>').html('False Action List').val('FalseActionList'))
    else if mylabel.match(/^ActionList_/)
      $('#node-to-add').append($('<option>').html('New Item').val('NewItem'))

  $('#node_id').val('1')
  update_listbox()

  update_event = ->
    return false if $('#node_id').val() == ''
    max = 0
    nodes.forEach (node) ->
      if !node.label.match(/^Action_/) && max <= node.level
        max = node.level

    nodes.forEach (node) ->
      if node.label.match(/^Action_/)
        nodes.update({
          id: node.id,
          level: max + 2
        })

    nodes.forEach (node) ->
      if node.label.match(/^[1-9][0-9]*$/)
        edges.forEach (edge) ->
          if edge.label == 'Do' && edge.from == node.id
            $('#node-to-add').val(edge.to)
    update_listbox()

  network.on 'click', (params) =>
    clickednodes = nodes.get(params.nodes)
    for node in clickednodes
      $('#node_id').val(node.id)
      $('#node_name').val(node.label)
      $('#node_desc').val(node.title)
      $('#node-to-add').val('Action')
      update_listbox()

  $('#node-to-add').on 'change', () =>
    return false if $('#node-to-add').val() == '0'
    if $('#node-to-add').val().match(/^(True|False)ActionList$/)
      add_bool()
    else if $('#node-to-add').val() == 'NewItem'
      add_action_item()
    else
      add_action()

    update_event()

  add_action = ->
    return false unless nodes.get($('#node_id').val()).label.match(/^[1-9][0-9]*/)
    new_id = 0
    unless $('#node-to-add').val().match(/^[1-9][0-9]*/)
      nodes.forEach (node) ->
        if new_id <= node.id
          new_id = parseInt(node.id) + 1
      new_level = 0
      if $('#node-to-add').val() == 'Action'
        nodes.forEach (node) ->
          if !node.label.match(/^Action_/) && new_level < node.level
            new_level = node.level
        new_level += 2
        new_color = { background:'lightgreen', border:'limegreen' }
      else if $('#node-to-add').val() == 'ActionList'
        new_level = 3
        new_color = { background:'cyan', border:'blue' }
      else
        new_level = 1
        new_color = { background:'pink', border:'purple' }

      nodes.add({
        id: new_id.toString(),
        level: new_level,
        shape: 'box',
        label: "#{$('#node-to-add').val()}_#{new_id}",
        font: { face: 'courier', align: 'left' },
        color: new_color
      })

    edge_id = false
    edges.forEach (edge) ->
      if edge.from == $('#node_id').val() && edge.label == 'Do'
        edge_id = edge.id

    if edge_id
      edges.update({
        id: edge_id,
        to: if new_id == 0 then $('#node-to-add').val() else new_id.toString(),
      })
    else
      edges.add({
        from: $('#node_id').val(),
        to: if new_id == 0 then $('#node-to-add').val() else new_id.toString(),
        label: 'Do',
        arrows: 'to'
      })

  last_child = (node_id) ->
    next_id = false
    edges.forEach (edge) ->
      if edge.from == node_id && edge.label != 'Do'
        next_id = edge.to
    if next_id
      last_child(next_id)
    else
      node_id

  add_action_item = ->
    return false unless nodes.get($('#node_id').val()).label.match(/^ActionList_/)
    mynode = nodes.get(last_child($('#node_id').val()))
    new_id = 0
    node_name =
      if mynode.label.match(/^([1-9]+[0-9]*)$/)
        (parseInt(mynode.label) + 1).toString()
      else
        '1'
    nodes.forEach (node) ->
      if new_id <= node.id
        new_id = parseInt(node.id) + 1
    nodes.add({
      id: new_id.toString(),
      label: node_name,
      level: mynode.level + 1,
      shape: 'circle',
      font: { face: 'courier', align: 'left' },
      color: { background:'moccasin', border:'orange' }
    })
    edges.add({
      from: mynode.id,
      to: new_id.toString()
    })

  add_bool = ->
    return false unless nodes.get($('#node_id').val()).label.match(/^Rule_/)
    if $('#node-to-add').val() == 'TrueActionList'
      mybool = 'True'
    else
      mybool = 'False'
    exists = false
    edges.forEach (edge) ->
      if edge.from == $('#node_id').val() && edge.label == mybool
        exists = true
    return if exists
    new_id = 0
    nodes.forEach (node) ->
      if new_id <= node.id
        new_id = parseInt(node.id) + 1
    nodes.add({
      id: new_id.toString(),
      level: nodes.get($('#node_id').val()).level + 2,
      shape: 'box',
      label: 'ActionList_' + new_id,
      font: { face: 'courier', align: 'left' },
      color: { background:'cyan', border:'blue' }
    })
    edges.add({
      from: $('#node_id').val(),
      to: new_id.toString(),
      label: mybool,
      arrows: 'to'
    })

  $('#remove-button').on 'click', () =>
    return if $('#node_id').val() == '1'
    haschild = false
    edges.forEach (edge) ->
      if edge.from == $('#node_id').val()
        haschild = true
    return false if haschild
    edges_remove = []
    edges.forEach (edge) ->
      if edge.to == $('#node_id').val() || edge.from == $('#node_id').val()
        edges_remove.push edge.id
        edges.label == ''

    edges.remove(edges_remove)
    nodes.remove($('#node_id').val())
    $('#node_id').val('')

  @oldVal = ""
  $("#node_desc").on "change keyup paste", ->
    currentVal = $(this).val()
    unless currentVal == @oldVal
      @oldVal = currentVal
      nodes.update({
        id: $('#node_id').val(),
        title: $('#node_desc').val(),
      })

  $('#form-submit').on 'click', () =>
    image_json = {
      nodes: [],
      edges: []
    }
    nodes.forEach (node) ->
      if node
        image_json.nodes.push node
    edges.forEach (edge) ->
      if edge
        image_json.edges.push edge
    $('#image_json').val(JSON.stringify(image_json))
    $('form').submit()
