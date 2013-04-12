require '../test_helper.coffee'

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

  it 'does not calculate results until trying to use the results array', ->
    run = false

    TestPlugin = Em.PipePlugin.extend
      process: (inputArr) ->
        run = true
        return inputArr

    pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
      content: []
      plugins: [TestPlugin]

    run.should.equal(false)

    # Trigger calculation
    pipeline.get('results')

    run.should.equal(true)