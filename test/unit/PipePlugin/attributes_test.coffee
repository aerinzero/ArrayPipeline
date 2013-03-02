require '../../test_helper.coffee'

beforeEach ->
  @pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin, 
    content: []
    plugins: [Em.PipePlugin]  

describe 'PipePlugin', ->

  describe 'attributes', ->

    it 'controller: should be able to get the ArrayPipeline', ->
      plugin = @pipeline.get('_processors.firstObject')
      plugin.get('controller').should.equal @pipeline

    # it 'prevResults: should be an array of previously computed results', ->
