
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
    @process()