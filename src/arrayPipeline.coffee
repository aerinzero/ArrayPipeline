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
  results: Ember.computed (key,value) ->
    # Getter
    if arguments.length == 1 
      # determine where to start processing
      processors = @get('_processors')

      # for each processor we have on and after the cursor, we want to trigger a recalculate
      forEach(processors, (processor) -> processor._recalculate() )

      # Return our last result set or our content if we have no processors
      if processors.length then return @get('_processors.lastObject._prevResults') else return @get('content')

    # Setter
    else

      return value  


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
    Returns back the previous results for a given PipePlugin.

    @method previousResults
    @param {Em.PipePlugin object} Em.PipePlugin instance from _processors
    @return {Array} results from the previous plugin's result set (or content array if first plugin)
  ###
  previousResults: (plugin) ->
    index = @get('_processors').indexOf(plugin)

    # Return no results if this plugin is not a part of the pipeline processors list
    return [] if index == -1

    # Return back our content array if this is the first plugin
    return @get('content')  if index == 0

    # Return back our _prevResults from our plugin if we are not the first one
    return @get('_processors').objectAt(index-1).get('_prevResults')

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
    @needsTest
  
    This is used for obtaining our observer keys that pertain to our controller

    @method _observerKeysForController
  ###
  _observerKeysForController: ( ->
    regex = new RegExp('^controller.(.+)$')
    observerKeys = []

    # Filter out only those keys beginning w/ controller and strip off the controller. prefix
    if @get('_observerMap')?
      @get('_observerMap').keys.toArray().forEach (key) ->
        match = key.match(regex)
        observerKeys.pushObject(match[1]) if match?

    return observerKeys
  ).property('_observerMap.@each')

  ###
    @private
    @needsTest
  
    This is used for obtaining our observer keys that pertain to our objects

    @method _observerKeysForController
  ###
  _observerKeysForObjects:( ->
    regex = new RegExp('^controller.(.+)$')

    # Filter out only those keys beginning w/ controller and strip off the controller. prefix
    if @get('_observerMap')?
      return @get('_observerMap').keys.toArray().filter (key) -> 
        return !key.match(regex)
    else
      return []
  ).property('_observerMap.@each')


  ###
    @private

    This is used to register all of the observers from our _observerMap onto each element of the content array.
    Additionally, if the observer matches "controller.<path>" it will register the observer onto the ArrayProxy/Controller

    @method _registerObservers
  ###
  _registerObservers: ->
    self = this
    content = @get('content') || []
    controller = @get('controller')
    objectKeys = @get('_observerKeysForObjects')
    controllerKeys = @get('_observerKeysForController')

    # For each object in our content array, we're going to add each observer key as an observer
    forEach( content, (item) ->
      forEach( objectKeys, (observerKey) ->
        item.addObserver(observerKey, self, self._processChanges)
      )
    )

    # For each controller observer key, we're going to add each observer of each key to our controller
    forEach( controllerKeys, (observerKey) ->
      self.addObserver(observerKey, self, self._processChanges)
    )

  ###
    @private
    @needsTest

    This is used to unregister all of the observers from our _observerMap for each element of the content array.

    @method _unregisterObservers
  ###
  _unregisterObservers: ->
    self = this
    content = @get('content') || []
    objectKeys = @get('_observerKeysForObjects')
    controllerKeys = @get('_observerKeysForController')

    # For each object in our content array, we're going to remove each observer key as an observer
    forEach( content, (item) ->
      forEach( objectKeys, (observerKey) ->
        item.removeObserver(observerKey, self, self._processChanges)
      )
    )

    # for each controllerkey, we should unregister from it as well
    forEach( controllerKeys, (observerKey) ->
      self.removeObserver(observerKey, self, self._processChanges)
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
    # If this is our controller object, we need to prepend "controller." to the change key
    changeKey = "controller.#{changeKey}" if changeObj == @

    # We start off by getting the position in the pipeline for where to recalculate changes
    beginProcessor = @get('_observerMap').get(changeKey)
    beginIndex = @get('_processors').indexOf(beginProcessor)

    # We recalculate for each processor on/after the given processor 
    processor._recalculate() for processor in @get('_processors')[beginIndex..]

    # We update our results to reflect
    results = @get('_processors.lastObject._prevResults')
    @set('results', results)


  ###
    @private
    @needsTest
    @todo
  
    Used to handle when our content array changes. 
    This needs to be implemented in a more efficient way

    @method pipelineContentWillChange
  ###
  pipelineContentWillChange: (-> @_unregisterObservers() ).observesBefore('content')

  ###
    @private
    @needsTest
    @todo
  
    Used to handle when our content array changes. 
    This needs to be implemented in a more efficient way

    @method pipelineContentDidChange
  ###
  pipelineContentDidChange: (-> @_registerObservers() ).observes('content')
