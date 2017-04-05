function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

function makeBitLayout(){
  var bytesize = document.getElementById("message_bytesize").value
  var signalnum = document.getElementById("signal_table").rows.length - 2

  var byte_order = "big_endian"
  var bitlayout=[]
  var sig_no;

  for (idx = 0; idx < bytesize; idx++) {
    bitlayout.push([0,0,0,0,0,0,0,0])
  }

  for (sig_no = 0; sig_no < signalnum; sig_no++) {
    var bit_offset = parseInt(document.getElementById("message_com_signals_attributes_"+String(sig_no)+"_bit_offset").value)
    var bit_size   = parseInt(document.getElementById("message_com_signals_attributes_"+String(sig_no)+"_bit_size").value)
    var byte_pos = Math.floor(bit_offset / 8)
    var bit_pos  = bit_offset % 8

    var bit;
    for (bit = 0; bit < bit_size; bit++) {
      if (bitlayout[byte_pos][bit_pos] == 0 ) {
        bitlayout[byte_pos][bit_pos] = sig_no+1
      } else {
        // レイアウト競合
        bitlayout[byte_pos][bit_pos] = -1
      }

      if (byte_order == "big_endian") {
        if (bit_pos == 0) {
          byte_pos++
          bit_pos=7
        } else {
          bit_pos--
        }
      }
      else {
        if (bit_pos == 7) {
          byte_pos++
          bit_pos=0
        } else {
          bit_pos++
        }
      }

      if ( byte_pos >= bytesize || byte_pos < 0) {
        break;
      }
    }
  }

  return bitlayout
}

function drawBitLayout(){
  var bytesize = document.getElementById("message_bytesize").value
  var signalnum = document.getElementById("signal_table").rows.length - 2
  var bitlayout = makeBitLayout()
//  var colors =       ['darkorange', 'teal'     'darkmagenta','navy',   'darkgreen']
  var colors =         ['#ff8c00',    '#008080', '#8b008b',    '#000080','#006400']

  // make html for bitLayoutTable
  var html = `<table class='table table-bordered'>`
  {
    html += "<tr><td>"

    var bit_pos
    for (bit_pos = 7; bit_pos >= 0; bit_pos--) {
      html +=  `<td>bit${String(bit_pos)}`
    }
  }

  var byte_pos
  for (byte_pos = 0; byte_pos < bytesize; byte_pos++) {
    html += "<tr>"
    html += `<td>byte${String(byte_pos)}`

    var bit_pos
    for (bit_pos = 7; bit_pos >= 0; bit_pos--) {
      var sig_no = bitlayout[byte_pos][bit_pos]
      if ( sig_no > 0) {
        color = colors[Math.floor((sig_no-1) % colors.length)]
      } else if (sig_no < 0){
        color = 'red'
      } else {
        color = 'lightgrey'
      }
      html += `<td bgcolor=${color} >`
    }

    html += "</tr>"
  }

  html += "</table>"
  document.getElementById("bitLayoutTable").innerHTML = html

  // paint signal_table
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
