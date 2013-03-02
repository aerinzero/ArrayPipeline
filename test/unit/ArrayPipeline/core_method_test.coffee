require '../../test_helper.coffee'

describe 'ArrayPipeline', ->

  describe 'plugin configuration', ->

    describe '#_initPlugin()', ->
      it 'should instantiate a plugin from a constant', ->
        pipeline = Em.ArrayProxy.createWithMixins(Em.ArrayPipelineMixin,{})
        pipeline.get('_processors.length').should.equal(0)
        pipeline._initPlugin(Em.PipePlugin)
        pipeline.get('_processors.length').should.equal(1)
        pipeline.get('_processors.firstObject').should.be.instanceof(Em.PipePlugin)

      it 'should instantiate a plugin from a string', ->
        pipeline = Em.ArrayProxy.createWithMixins(Em.ArrayPipelineMixin,{})
        pipeline.get('_processors.length').should.equal(0)
        pipeline._initPlugin('Em.PipePlugin')
        pipeline.get('_processors.length').should.equal(1)
        pipeline.get('_processors.firstObject').should.be.instanceof(Em.PipePlugin)
        
    describe '#_configurePlugins()', ->
    

