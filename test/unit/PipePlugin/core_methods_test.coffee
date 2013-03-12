require '../../test_helper.coffee'


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


describe 'PipePlugin', ->
  describe 'processing', ->
    describe '#process', ->
      it 'should always have an array passed as input', ->
        pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin, 
          content: null
          plugins: [FooPlugin]

        fooPlugin = pipeline.get('_processors.firstObject')

        fooPlugin.process = (inputArr) ->
          inputArr.should.be.instanceof(Array)

        pipeline.get('results')

    describe '#_lastResult()', ->
      it 'should obtain the results from the previous plugin', ->
        fooPlugin = @pipeline.get('_processors.firstObject')
        barPlugin = @pipeline.get('_processors.lastObject')

        fooPlugin.process = (inputArr) ->
          return inputArr.map (item) -> return 1


        # Trigger calculation
        @pipeline.get('results')

        # Test to see if barPlugin can get fooResults
        fooResults = barPlugin._lastResult()
        fooResults.should.deep.equal([1,1])
         


    describe '#_recalculate()', ->
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
        fooPlugin = @pipeline.get('_processors.firstObject')
        fooPlugin.should.be.instanceof(FooPlugin)

        fooPlugin.process = (inputArr) ->
          return inputArr.map (item) -> return 1

        expectedArr = [1,1]

        @pipeline.get('results').should.deep.equal(expectedArr)
        fooPlugin.get('_prevResults').should.deep.equal(expectedArr)


      it 'should trigger the next plugins recalculate method if there is one', ->
      it 'should update results on the pipeline if this is the last plugin', ->

