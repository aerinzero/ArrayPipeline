
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