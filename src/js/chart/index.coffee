###
# chart/index.coffee
###

GENERATION_STEP = 512

class Chart
  constructor: (args) ->
    @_args = args
    @_renderedData = [args.name].concat(null for d in args.data)
    @_shadowData = ['Shadow'].concat(
      (if args.transform? then args.data.map(args.transform) else args.data)
    )
    config =
      bindto: args.bindto
      transition:
        duration: 0
      point:
        r: 0
        focus:
          expand:
            r: 7
            enabled:
              true
      data:
        colors: {}
        columns: [
          @_shadowData
          @_renderedData
        ]
      axis:
        x:
          tick:
            count: 10
            culling: true
            format: (x) -> x * GENERATION_STEP
          padding:
            left: 0
            right: 0
          label:
            show: true
            text: 'Generation'
            position: 'outer-center'
        y:
          padding:
            top: 0
            bottom: 0
      legend:
        show: false
      grid:
        y:
          show: false
    config.data.colors[args.name] = args.color
    config.data.colors['Shadow'] = '#ccc'
    config.axis.y.min = args.min
    config.axis.y.max = args.max
    if args.padding? then config.axis.y.padding = args.padding

    @_chart = c3.generate(config)

  _update: =>
    @_chart.load(columns: [@_shadowData, @_renderedData])

  load: (dataIndex) =>
    d = @_args.data[dataIndex]
    y = (if @_args.transform? then @_args.transform(d) else d)
    @_renderedData[dataIndex + 1] = y
    @_update()

  clear: =>
    @_renderedData = [args.name].concat(null for d in args.data)
    @_update()

module.exports = Chart
