require '../../test_helper.coffee'

describe 'Init: ArrayPipeline', ->

  it 'has equal results and content arrays when no plugins are defined', ->
    sourceArray = ['one','two','three']
      
    pipeline = Em.ArrayProxy.createWithMixins Ember.ArrayPipelineMixin,
      content: sourceArray

    sourceArray.should.equal pipeline.get('results')

  it 'has an empty results array if content is null', ->
    sourceArray = null
    pipeline = Em.ArrayProxy.createWithMixins Ember.ArrayPipelineMixin,
      content: sourceArray
    expect(pipeline.get('results')).to.be.instanceof(Array)

  it 'has an empty results array if content is undefined', ->
    sourceArray = undefined
    pipeline = Em.ArrayProxy.createWithMixins Ember.ArrayPipelineMixin,
      content: sourceArray
    expect(pipeline.get('results')).to.be.instanceof(Array)
