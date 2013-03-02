Ember.ArrayPipelineMixin = Ember.Mixin.create

  # This is our result output from the ArrayPipeline
  results: []

  # Initial Pipeline Setup
  init: -> 
    @_super()
    @set('results', @get('content')) if @get('content')?
