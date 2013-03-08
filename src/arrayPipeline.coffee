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

    A map of observer properties to plugin instances.  Used for determining which plugin to fire on
    an observation change.

    @property _observerMap
    @type Em.Map
    @default {}
  ###
  _observerMap: null


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

    # Configure our observer map
    @_configureObserverMap()

    # Register our observers
    @_registerObservers()

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



  ###
    @private

    This is used to configure an observer map for all of our instantiated plugins.

    @method _configureObserverMap
  ###
  _configureObserverMap: ->
    map = Em.Map.create()

    # For each processor we have, we'll want to set the observe properties on the map if it isn't set already
    forEach( @get('_processors'), (processor) ->
      forEach( processor.get('observes'), (observer) ->
        map.set(observer, processor) if !map.get(observer)
      )
    )

    @set '_observerMap', map

  ###
    @private

    This is used to register all of the observers from our _observerMap onto each element of the content array.

    @method _registerObservers
  ###
  _registerObservers: ->
    self = this

    # For each object in our content array, we're going to add each observer key as an observer
    forEach( @get('content'), (item) ->
      forEach( self.get('_observerMap').keys.toArray(), (observerKey) ->
        item.addObserver(observerKey, self, self._processChanges)
      )
    )   

  ###
    @private

    This is used to handle inbound observation changes for any element in our content array.
    It will look up the appropriate plugin to trigger a reprocess on.

    @method _processChanges
    @param {Em.Object} object that is changing
    @param {String} key that is changing
  ###
  _processChanges: (changeObj, changeKey) ->

