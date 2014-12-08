###
# chart/index.coffee
###

NUMBER_OF_GENERATIONS = 59904
GENERATION_STEP = 512

class Chart
  constructor: (args) ->
    @args = args
    @graph = @_init(args)

  _init: (args) ->
    graph = new Rickshaw.Graph(
      element: args.element
      renderer: 'line'
      width: args.width
      height: args.height
      min: 0
      max: 1
      series: [
        {
          name: args.name
          color: args.color
          data: []
          scale: args.scale
        }
      ]
    )

    graph.addData = (d) =>
      graph.series[0].data.push(
        x: graph.series[0].data.length + 1
        y: d[args.name]
      )

    xAxis = new Rickshaw.Graph.Axis.X(
      graph: graph
      orientation: 'top'
      tickSize: 5
      tickFormat: (n) ->
        if n < 0 then null else n * GENERATION_STEP
    )
    yAxis = new Rickshaw.Graph.Axis.Y.Scaled(
      graph: graph
      grid: true
      orientation: 'right'
      scale: args.scale
      tickSize: 5
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
    )
    hoverDetail = new Rickshaw.Graph.HoverDetail(
      graph: graph
    )
    graph.render()
    return graph


  clear: =>
    $(@args.element).html('')
    @graph = @_init(@args)
    @graph.render()

  load: (data) =>
    @graph.addData(data)
    @graph.render()

module.exports = Chart
