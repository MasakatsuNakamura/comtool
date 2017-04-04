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
  var colors = ['limegreen','olive','darkgreen','darkslategray', 'royalblue','turquoise','teal',]

  var tbl_heght = String(50 * bytesize)
  var tbl_width = String(50)

  // make html for bitLayoutTableLegend
//  var html = `<table class='table table-bordered' height=${tbl_heght} width=${tbl_width}>`
  var html = `<table class='table'>`
  {
    html += "<tr>"

    var sig_no
    for (sig_no = 0; sig_no < signalnum; sig_no++) {
      color = colors[Math.floor((sig_no-1) % colors.length)]
      sig_name = document.getElementById("message_com_signals_attributes_"+String(sig_no)+"_name").value
      html += `<th bgcolor=${color} ><th>${sig_name}`
    }
    html += '<tr>'
    html += `<th bgcolor='red' ><th>重複`
    html += `<th bgcolor='lightgrey'><th>未割付`
    html += `</th>`
  }
  document.getElementById("bitLayoutTableLegend").innerHTML = html


  // make html for bitLayoutTable
  var html = `<table class='table table-bordered' height=${tbl_heght} width=${tbl_width}>`

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
}
