set = Em.set
get = Em.get
forEach = Em.EnumerableUtils.forEach

Ember.ArrayPipelineMixin = Ember.Mixin.create

  ###
    The result output from the ArrayPipeline after all processing has been done.

    @property results
    @type Array
    @default []
  ###
  results: (->
    # determine where to start processing
    processors = @get('_processors')

    # determine which result set to pass in to the first processor
    results = @get('content')

    # for each processor we have on and after the cursor, we want to
      # process
      # cache results on the plugin
      # pass results to the next plugin
    forEach(processors, (processor) ->
      results = processor.process(results)
    )

    # Return our last result set
    return results 
  ).property()


  ###
    An array of plugins to use for processing.  It's okay to mix constants and strings as part of 
    this definition.

    @property plugins
    @type Array
    @default []
  ###
  plugins: null


  ###
    @private

    An Array of instantiated plugins to use for the processing.
  
    @property _processors
    @type Array
    @default []
  ###
  _processors: null


  ###
    @private
  
    Construct the pipeline plugins, register observers, and begin processing on our Array content.

    @method init
  ### 
  init: -> 
    @_super()

    # Set our content to a blank array if we do not have a content array set
    @set 'content', [] if !@get('content')?

    # Configure each of our PipePlugins
    @_configurePlugins()


  ###
    @private

    Take in a constant or string of a PipePlugin, and push an instance of the plugin into our 
    _processors array.
  
    TODO: Assertions for classes passed in that are not defined

    @method _initPlugin
    @param {Em.PipePlugin} plugin 
  ###
  _initPlugin: (plugin) ->
    plugin = get(plugin) if typeof plugin == 'string'
    @get('_processors').pushObject plugin.create( controller: @ )


  ###
    @private

    Setup our plugin instances on init.

    @method _configurePlugins
  ###
  _configurePlugins: ->
    @set 'plugins', [] if !@get('plugins')?
    @set '_processors', []
    @get('plugins').forEach (plugin) => @_initPlugin plugin

