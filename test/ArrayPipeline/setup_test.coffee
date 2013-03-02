require '../test_helper.coffee'

beforeEach ->
  @sourceArray = Em.A(['one','two','three'])
  
  @pipeline = Em.ArrayProxy.createWithMixins Ember.ArrayPipelineMixin,
    content: @sourceArray

describe 'Setup: ArrayPipeline', ->

  it 'has equal results and content arrays when no plugins are defined' ->
    @sourceArray.should.equal @pipeline.get('results')
