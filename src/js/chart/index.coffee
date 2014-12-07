###
# chart/index.coffee
###

CHART_SELECTOR = '#chart'
PHI_AXIS_ID = 'phi-axis'
FITNESS_AXIS_SELECTOR = '#fitness-axis'
X_AXIS_SELECTOR = '#x-axis'

NUMBER_OF_GENERATIONS = 59904
GENERATION_STEP = 512
X_MAX = Math.ceil(NUMBER_OF_GENERATIONS / GENERATION_STEP)

PHI_RANGE = [0, 2]
FITNESS_RANGE = [0, 200]

width = 528
height = 200

graph = undefined
xAxis = undefined
phiAxis = undefined
fitnessAxis = undefined

scales =
  phi: d3.scale.linear().domain(PHI_RANGE).nice()
  fitness: d3.scale.linear().domain(FITNESS_RANGE).nice()


exports.init = ->
  graph = new Rickshaw.Graph(
    element: document.querySelector(CHART_SELECTOR)
    renderer: 'line'
    width: width
    height: height
    # min: 0
    # max: 1
    series: [
      {
        name: 'phi'
        color: '#268bd2'
        data: []
        scale: scales.phi
      }
      {
        name: 'fitness'
        color: '#859900'
        data: []
        scale: scales.fitness
      }
    ]
  )

  graph.addData = (d) ->
    phiData = graph.series[0].data
    fitnessData = graph.series[1].data
    phiData.push(
      x: phiData.length + 1
      y: d.phi
    )
    fitnessData.push(
      x: fitnessData.length + 1
      y: d.fitness
    )

  xAxis = new Rickshaw.Graph.Axis.X(
    # element: document.querySelector(X_AXIS_SELECTOR)
    graph: graph
    orientation: 'top'
    tickSize: 10
    tickFormat: (n) ->
      if n < 0 then null else n * GENERATION_STEP
  )
  phiAxis = new Rickshaw.Graph.Axis.Y.Scaled(
    # element: document.getElementById(PHI_AXIS_ID)
    graph: graph
    grid: false
    orientation: 'right'
    scale: scales.phi
    tickSize: 5
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
  )
  fitnessAxis = new Rickshaw.Graph.Axis.Y.Scaled(
    # element: document.querySelector(FITNESS_AXIS_SELECTOR)
    graph: graph
    grid: false
    scale: scales.fitness
    orientation: 'left'
    tickSize: 10
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
  )
  # legend = new Rickshaw.Graph.Legend(
  #   graph: graph
  #   element: document.querySelector(CHART_SELECTOR)
  # )
  # highlighter = new Rickshaw.Graph.Behavior.Series.Highlight(
  #   graph: graph
  #   legend: legend
  # )
  hoverDetail = new Rickshaw.Graph.HoverDetail(
    graph: graph
  )
  graph.render()


exports.load = (data) ->
  graph.addData(data)
  graph.render()
