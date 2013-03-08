require '../../test_helper.coffee'

describe 'PipePlugin', ->
  describe 'processing', ->

    describe '#_recalculate()', ->

      Book = Em.Object.extend
        name: null
        year: null

      FooPlugin = Em.PipePlugin.extend
        observes: ['name']

      BarPlugin = Em.PipePlugin.extend
        observes: []

      beforeEach ->
        @pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin, 
          content: [
            Book.create( name: 'foo', year: 1254 )
            Book.create( name: 'bar', year: 515 )
          ]

          plugins: [FooPlugin, BarPlugin]

      it 'should trigger #process()', ->
        fooPlugin = @pipeline.get('_processors.firstObject')
        fooPlugin.should.be.instanceof(FooPlugin)

        ran = false
        fooPlugin.process = (inputArr) ->
          ran = true
          return inputArr

        ran.should.equal(false)
        fooPlugin._recalculate()
        ran.should.equal(true)


      it 'should cache processed results into _prevResults', ->
      it 'should trigger the next plugins recalculate method if there is one', ->
      it 'should update results on the pipeline if this is the last plugin', ->

