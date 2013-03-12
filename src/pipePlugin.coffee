
Em.PipePlugin = Em.Object.extend
  
  ###
    Controller points to the ArrayProxy that contains the ArrayPipelineMixin.

    @property controller
    @type Ember.ArrayProxy
  ###
  controller: null

  ###
    Observes is the list of properties that the given PipePlugin is interested in watching.
    Set a list of string paths for the properties that you would like to observe.

    @property observes
    @type Array
  ###
  observes: null

  ###
    Holds a cached version of our previous result run (to be used for recalculation events).

    @property _prevResults
    @type Array
  ###
  _prevResults: null

  ###
    Method used for taking in array input, processing, and returning output to the next plugin in the chain.
    Each PipePlugin instance needs to override this method.

    @method process
    @param {Array}
    @return {Array}
  ###
  process: (inputArr) -> return inputArr

  ###
    @private
    Additional setup on initialize.

    @method init
  ###
  init: ->
    @_super()
    @set('observes', []) if !@get('observes')?


  ###
    @private
    This method is responsible for recalculating changes from the previous pipeline's result set.
    It should:
      1) Fetch previous plugin's results
      2) Pass those into process
      3) Cache processed results
      4a) Trigger the next plugin's recalculate method
      4b) Update 'results' on the pipeline if this was the last plugin to execute

    @method _recalculate
  ###
  _recalculate: ->
    results = @process(@_lastResult())
    @set('_prevResults', results)


  ###
    @private

    This method will obtain the results used from the previous pipeline operation.  If there is not a plugin
    prior to this one in the pipeline, it will be equal to the content array.

    @method _lastResult
  ###
  _lastResult: ->
    @get('controller').previousResults(@)