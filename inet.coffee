command: "python3 inet.widget/check.py"
refreshFrequency: 3000000
render: (output) -> """
<table class="inet"></table>
"""

update: (output, domEl) ->
  max_rows = 24
  packet_loss_threshold = 0.2
  table = $(domEl).find('.inet')
  
  preperedRow = (data) ->

    row = $("""
  <tr class="row">
			<td class="url text"></td>
			<td class="status text"></td>
      <td class="avg text"></td>
      <td class="chart"></td>
		</tr>
  """)
    storageKey = 'com.avm.inetStore'
    avg_ = data['avg']
    
    host_ = data['host']
    row.find('.url').html(host_)
    if data['is_alive']==true 
      icon = '<i class="gg-shape-circle"></i>'
      row.find('.avg').html(avg_.toFixed(2))
    else
      icon ='<i class="gg-danger"></i>'
      row.find('.avg').html('---.--')
    row.find('.status').html(icon)
    totals = JSON.parse(localStorage.getItem(storageKey))
    if totals == null
      totals = {}
    if not totals.hasOwnProperty(host_)
      totals[host_] = []
    if totals[host_].length == max_rows
      totals[host_].shift 1
    totals[host_].push avg_
    sorted = totals[host_].slice(0)
    sorted.sort (a,b) ->
      a-b
    max = sorted[sorted.length - 1]
    min = sorted[0]
    div = (max - min) / (1000 / max_rows) / .15
    chart = row.find('.chart')
    i = 0
    while i < max_rows
      chart.append('<div class="bar">')
      i++

    i = 0
    while i < max_rows
      load = totals[host_][i]
      value = ((load - min) / div)
      $bar = $($(row).find('.bar').get(i))
      $bar.css
        paddingTop: value + 2 + '%'
        left: (i * 7.5) + 'px'
      i++
    $(row).find('.chart').append chart
    localStorage.setItem(storageKey, JSON.stringify(totals))
    $(row)


    
  table.html('')
  content_ = $(domEl).find '#inet'
  data_ = JSON.parse(output)
  for el in data_
    avg_ = el['avg']
    host_ = el['host']
    is_alive = el['is_alive']
    preperedRow(el)
    table.append preperedRow(el)
  
style: """
color: white
left: 0px
top: 10px
width 428px
font-size: 10px
font-family: SFNS Display, 'Andale Mono', sans-serif
text-shadow: 1px 1px 0 rgba(#000, 0.2)
background-color: rgba(255, 255, 255, 0.1)
border-radius: 6px
border: 0px solid #222




.text
  font-size 14px
  padding 10px
  padding-top 14px 

.url
  width 100px !important

.chart
  position relative
  padding 6px 0 0 6px
  height 25px
  width 175px
  box-sizing border-box
  border-bottom-style: solid !important
  border-bottom-width: 10px !important 
  margin-bottom: 10px !important;
  border-color rgba(0, 0, 0, 0.0)

.bar
  color rgba(#fff,.65)
  font-size 10px
  text-align center
  display block
  font-family Menlo
  border-left 4px solid white
  width 9px
  bottom 0
  padding 0
  line-height 1
  position absolute

&.animated .bar
  -webkit-backface-visibility hidden;
  -webkit-perspective 1000;
  -webkit-transform translate3d(0, 0, 0);
  transition all 4s linear

.bar
  opacity .4

.gg-danger
  box-sizing: border-box;
  position: relative;
  display: block;
  transform: scale(var(--ggs,1));
  width: 20px;
  height: 20px;
  border: 2px solid;
  border-radius: 40px
  color: rgb(244, 115, 94)
  

.gg-danger::after, .gg-danger::before 
  content: "";
  display: block;
  box-sizing: border-box;
  position: absolute;
  border-radius: 3px;
  width: 2px;
  background: currentColor;
  left: 7px


.gg-danger::after
  top: 2px;
  height: 8px


.gg-danger::before
  height: 2px;
  bottom: 2px

.gg-shape-circle
  box-sizing: border-box;
  position: relative;
  display: block;
  transform: scale(var(--ggs,1));
  width: 20px;
  height: 20px;
  border: 3px solid;
  border-radius: 100px
  color: rgb(0, 255, 0)
"""
