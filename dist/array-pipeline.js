(function() {
  var forEach, get, set;

  set = Em.set;

  get = Em.get;

  forEach = Em.EnumerableUtils.forEach;

  Ember.ArrayPipelineMixin = Ember.Mixin.create({
    /*
      The result output from the ArrayPipeline after all processing has been done.
    
      @property results
      @type Array
      @default []
    */

    results: Ember.computed('content', function(key, value) {
      if (arguments.length === 1) {
        return this._recalculatedResults();
      } else {
        return value;
      }
    }),
    /*
      An array of plugins to use for processing.  It's okay to mix constants and strings as part of
      this definition.
    
      @property plugins
      @type Array
      @default []
    */

    plugins: null,
    /*
      @private
    
      An Array of instantiated plugins to use for the processing.
    
      @property _processors
      @type Array
      @default []
    */

    _processors: null,
    /*
      @private
    
      A map of observer properties to plugin instances.  Used for determining which plugin to fire on
      an observation change.
    
      @property _observerMap
      @type Em.Map
      @default {}
    */

    _observerMap: null,
    /*
      Returns back the previous results for a given PipePlugin.
    
      @method previousResults
      @param {Em.PipePlugin object} Em.PipePlugin instance from _processors
      @return {Array} results from the previous plugin's result set (or content array if first plugin)
    */

    previousResults: function(plugin) {
      var index;

      index = this.get('_processors').indexOf(plugin);
      if (index === -1) {
        return [];
      }
      if (index === 0) {
        return this.get('content');
      }
      return this.get('_processors').objectAt(index - 1).get('_prevResults');
    },
    /*
      @private
    
      Construct the pipeline plugins, register observers, and begin processing on our Array content.
    
      @method init
    */

    init: function() {
      this._super();
      if (this.get('content') == null) {
        this.set('content', []);
      }
      this._configurePlugins();
      this._configureObserverMap();
      return this._registerObservers();
    },
    /*
      @private
    
      Take in a constant or string of a PipePlugin, and push an instance of the plugin into our
      _processors array.
    
      TODO: Assertions for classes passed in that are not defined
    
      @method _initPlugin
      @param {Em.PipePlugin} plugin
    */

    _initPlugin: function(plugin) {
      if (typeof plugin === 'string') {
        plugin = get(plugin);
      }
      return this.get('_processors').pushObject(plugin.create({
        controller: this
      }));
    },
    /*
      @private
    
      Setup our plugin instances on init.
    
      @method _configurePlugins
    */

    _configurePlugins: function() {
      var _this = this;

      if (this.get('plugins') == null) {
        this.set('plugins', []);
      }
      this.set('_processors', []);
      return this.get('plugins').forEach(function(plugin) {
        return _this._initPlugin(plugin);
      });
    },
    /*
      @private
    
      This is used to configure an observer map for all of our instantiated plugins.
    
      @method _configureObserverMap
    */

    _configureObserverMap: function() {
      var map;

      map = Em.Map.create();
      forEach(this.get('_processors'), function(processor) {
        return forEach(processor.get('observes'), function(observer) {
          if (!map.get(observer)) {
            return map.set(observer, processor);
          }
        });
      });
      return this.set('_observerMap', map);
    },
    /*
      @private
      @needsTest
    
      This is used for obtaining our observer keys that pertain to our controller
    
      @method _observerKeysForController
    */

    _observerKeysForController: (function() {
      var observerKeys, regex;

      regex = new RegExp('^controller.(.+)$');
      observerKeys = [];
      if (this.get('_observerMap') != null) {
        this.get('_observerMap').keys.toArray().forEach(function(key) {
          var match;

          match = key.match(regex);
          if (match != null) {
            return observerKeys.pushObject(match[1]);
          }
        });
      }
      return observerKeys;
    }).property('_observerMap.@each'),
    /*
      @private
      @needsTest
    
      This is used for obtaining our observer keys that pertain to our objects
    
      @method _observerKeysForController
    */

    _observerKeysForObjects: (function() {
      var regex;

      regex = new RegExp('^controller.(.+)$');
      if (this.get('_observerMap') != null) {
        return this.get('_observerMap').keys.toArray().filter(function(key) {
          return !key.match(regex);
        });
      } else {
        return [];
      }
    }).property('_observerMap.@each'),
    /*
      @private
    
      This is used to register all of the observers from our _observerMap onto each element of the content array.
      Additionally, if the observer matches "controller.<path>" it will register the observer onto the ArrayProxy/Controller
    
      @method _registerObservers
    */

    _registerObservers: function() {
      var content, controller, controllerKeys, objectKeys, self;

      self = this;
      content = this.get('content') || [];
      controller = this.get('controller');
      objectKeys = this.get('_observerKeysForObjects');
      controllerKeys = this.get('_observerKeysForController');
      forEach(content, function(item) {
        return forEach(objectKeys, function(observerKey) {
          return item.addObserver(observerKey, self, self._processChanges);
        });
      });
      return forEach(controllerKeys, function(observerKey) {
        return self.addObserver(observerKey, self, self._processChanges);
      });
    },
    /*
      @private
      @needsTest
    
      This is used to unregister all of the observers from our _observerMap for each element of the content array.
    
      @method _unregisterObservers
    */

    _unregisterObservers: function() {
      var content, controllerKeys, objectKeys, self;

      self = this;
      content = this.get('content') || [];
      objectKeys = this.get('_observerKeysForObjects');
      controllerKeys = this.get('_observerKeysForController');
      forEach(content, function(item) {
        return forEach(objectKeys, function(observerKey) {
          return item.removeObserver(observerKey, self, self._processChanges);
        });
      });
      return forEach(controllerKeys, function(observerKey) {
        return self.removeObserver(observerKey, self, self._processChanges);
      });
    },
    /*
      @private
    
      This is used to handle inbound observation changes for any element in our content array.
      It will look up the appropriate plugin to trigger a reprocess on.
    
      @method _processChanges
      @param {Em.Object} object that is changing
      @param {String} key that is changing
    */

    _processChanges: function(changeObj, changeKey) {
      var beginIndex, beginProcessor, processor, results, _i, _len, _ref;

      beginProcessor = this.get('_observerMap').get(changeKey);
      beginIndex = this.get('_processors').indexOf(beginProcessor);
      _ref = this.get('_processors').slice(beginIndex);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        processor = _ref[_i];
        processor._recalculate();
      }
      results = this.get('_processors.lastObject._prevResults');
      return this.set('results', results);
    },
    /*
      @private
      @needsTest
      @todo
    
      Used to handle when our content array changes.
      This needs to be implemented in a more efficient way
    
      @method pipelineContentWillChange
    */

    pipelineContentWillChange: (function() {
      return this._unregisterObservers();
    }).observesBefore('content'),
    /*
      @private
      @needsTest
      @todo
    
      Used to handle when our content array changes.
      This needs to be implemented in a more efficient way
    
      @method pipelineContentDidChange
    */

    pipelineContentDidChange: (function() {
      return this._registerObservers();
    }).observes('content'),
    /*
      @private
    
      This method recalcuates all changes in the Pipeline and returns the results
      array with the recalculations.
    
      @method _recalculatedResults
    */

    _recalculatedResults: function() {
      var processors;

      processors = this.get('_processors');
      forEach(processors, function(processor) {
        return processor._recalculate();
      });
      if (processors.length) {
        return this.get('_processors.lastObject._prevResults');
      } else {
        return this.get('content');
      }
    },
    /*
      Used to handle when an item is added or removed from our content array
    */

    arrayContentDidChange: function(startIdx, removeAmt, addAmt) {
      var newItems, objectKeys, results, self;

      this._super(startIdx, removeAmt, addAmt);
      if (addAmt > 0) {
        self = this;
        newItems = this.get('content').slice(startIdx, addAmt);
        objectKeys = this.get('_observerKeysForObjects');
        forEach(newItems, function(item) {
          return forEach(objectKeys, function(observerKey) {
            return item.addObserver(observerKey, self, self._processChanges);
          });
        });
        results = this._recalculatedResults();
        this.set('results', results);
      }
      if (removeAmt > 0) {
        return 0;
      }
    }
  });

  Em.PipePlugin = Em.Object.extend({
    /*
      Controller points to the ArrayProxy that contains the ArrayPipelineMixin.
    
      @property controller
      @type Ember.ArrayProxy
    */

    controller: null,
    /*
      Observes is the list of properties that the given PipePlugin is interested in watching.
      Set a list of string paths for the properties that you would like to observe.
    
      @property observes
      @type Array
    */

    observes: null,
    /*
      Holds a cached version of our previous result run (to be used for recalculation events).
    
      @property _prevResults
      @type Array
    */

    _prevResults: null,
    /*
      Method used for taking in array input, processing, and returning output to the next plugin in the chain.
      Each PipePlugin instance needs to override this method.
    
      @method process
      @param {Array}
      @return {Array}
    */

    process: function(inputArr) {
      return inputArr;
    },
    /*
      @private
      Additional setup on initialize.
    
      @method init
    */

    init: function() {
      this._super();
      if (this.get('observes') == null) {
        return this.set('observes', []);
      }
    },
    /*
      @private
      This method is responsible for recalculating changes from the previous pipeline's result set.
      It should:
        1) Fetch previous plugin's results
        2) Pass those into process
        3) Cache processed results
        4a) Trigger the next plugin's recalculate method
        4b) Update 'results' on the pipeline if this was the last plugin to execute
    
      @method _recalculate
    */

    _recalculate: function() {
      var lastResult, results;

      lastResult = this._lastResult() || [];
      results = this.process(lastResult);
      return this.set('_prevResults', results);
    },
    /*
      @private
    
      This method will obtain the results used from the previous pipeline operation.  If there is not a plugin
      prior to this one in the pipeline, it will be equal to the content array.
    
      @method _lastResult
    */

    _lastResult: function() {
      return this.get('controller').previousResults(this);
    }
  });

}).call(this);
