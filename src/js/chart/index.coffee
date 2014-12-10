###
# chart/index.coffee
###

class Chart
  constructor: (args) ->
    @_args = args
    if args.transform? then @_args.data = args.data.map(args.transform)
    @_renderedData = [args.name]
      .concat(null for d in args.data)
    @_shadowData = ['Shadow']
      .concat(@_args.data)
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
          padding:
            left: 0
            right: 0
          label:
            show: true
            text: 'Generation'
            position: 'outer-center'
        y:
          tick:
            count: 4
            format: (x) -> d3.round(x, 2)
          padding:
            top: 0
            bottom: 0
      legend:
        show: false
    config.data.colors[args.name] = args.color
    config.data.colors['Shadow'] = '#ccc'
    config.axis.y.min = args.min
    config.axis.y.max = args.max
    if args.grid? then config.grid = args.grid
    if args.xTickFormat? then config.axis.x.tick.format = args.xTickFormat

    @_chart = c3.generate(config)

  _update: =>
    @_chart.load(columns: [@_shadowData, @_renderedData])

  load: (dataIndex) =>
    d = @_args.data[dataIndex]
    @_renderedData = [@_args.name]
      .concat(@_args.data[0...(dataIndex + 1)])
      .concat(null for i in [(dataIndex + 1)...@_args.data.length])
    @_update()

  clear: =>
    @_renderedData = [@_args.name]
      .concat(null for d in @_args.data)
    @_update()

module.exports = Chart
