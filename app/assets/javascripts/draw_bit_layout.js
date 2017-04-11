function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

function bitLayoutTableValue() {
  return {CONFLICT:0, UNUSED:-1, OUT_OF_RANGE:-2}
}

function makeBitLayout(){
  var bytesize = $("#message_bytesize").val()

  var byte_order = "big_endian"
  var bitlayout=[
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0],
  ]
  var sig_no;

  var const_bit = bitLayoutTableValue()

  var byte,bit
  for (byte = 0; byte < 8; byte++) {
    for (bit = 7; bit >= 0; bit--) {
      if (byte < bytesize) {
        bitlayout[byte][bit] = const_bit.UNUSED
      } else {
        bitlayout[byte][bit] = const_bit.OUT_OF_RANGE
      }
    }
  }

  var signalnum = $("#signal_table")[0].rows.length - 2
  for (sig_no = 0; sig_no < signalnum; sig_no++) {
    var bit_offset = parseInt($(`#message_com_signals_attributes_${String(sig_no)}_bit_offset`).val())
    var bit_size   = parseInt($(`#message_com_signals_attributes_${String(sig_no)}_bit_size`).val())
    var byte = Math.floor(bit_offset / 8)
    var bit  = bit_offset % 8

    var bit_cnt;
    var l = bitlayout
    for (bit_cnt = 0; bit_cnt < bit_size; bit_cnt++) {
      if (l[byte][bit] < 0 ) { l[byte][bit] = sig_no+1
      } else {                 l[byte][bit] = const_bit.CONFLICT}

      if (byte_order == "big_endian") {
        if (bit == 0) { byte++; bit=7;}
        else          {         bit--;}
      }
      else { // little_endian
        if (bit == 7) { byte++; bit=0;}
        else          {         bit++;}
      }
    }
  }

  return bitlayout
}

function paintBitLayout(){
  var bitlayout = makeBitLayout()
//  var colors =       ['darkorange', 'teal'     'darkmagenta','navy',   'darkgreen']
  var colors =         ['#ff8c00',    '#008080', '#8b008b',    '#000080','#006400']

  //items
  var bytesize =  parseInt($("#message_bytesize").val())
  $('#bitLayoutTable td').each(function() {
    var byte = $(this).parent()[0].rowIndex - 1
    var bit  = 7 - $(this)[0].cellIndex + 1

    var const_bit = bitLayoutTableValue()
    if (byte >= 0 && bit < 8) {
      var sig_no = bitlayout[byte][bit]
      if ( sig_no > 0) {
        color = colors[Math.floor((sig_no-1) % colors.length)]
      } else if (sig_no == const_bit.CONFLICT){
        color = 'red'
      } else if (sig_no == const_bit.OUT_OF_RANGE){
        color = 'dimgray'
      } else { // const_bit.UNUSED
        color = 'lightgrey'
      }

      $(this).css('background-color', `${color}`);
    }

    if ($(this)[0].cellIndex == 0){
      if (byte < bytesize) {
        $(this).css('background-color', `white`);
      }else{
        $(this).css('background-color', `dimgray`);
      }
    }
  });

  var sig_colors = []
  $('#signal_table tr').each(function() {
    if ($(this)[0].rowIndex > 1) {
      if (sig_colors.length==0) sig_colors = colors.concat()

      var c = hexToRgb(sig_colors.shift())
      $(this).css('background-color', `rgba(${c.r},${c.g},${c.b},0.3)`);
    }
   });

   $('#signal_table a').each(function() {
     $(this).parent().css('background-color', `white`);
   });
}

function initBitLayoutTable(){
  // make html for bitLayoutTable
  var html = ""

  //header
  html += "<tr><th>"

  var bit
  for (bit = 7; bit >= 0; bit--) {
    html +=  `<th>bit${String(bit)}`
  }

  //items
  var byte,bit
  for (byte = 0; byte < 8; byte++) {
    html += `<tr>`
    html += `<td>byte${String(byte)}`

    for (bit = 7; bit >= 0; bit--) {
      html += `<td>`
    }
  }

  $('#bitLayoutTable').html(html)

  $("#message_bytesize").change(paintBitLayout)
  $("#signal_table").change(paintBitLayout)

  paintBitLayout()
}
