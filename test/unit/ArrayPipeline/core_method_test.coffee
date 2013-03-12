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

      it 'should create instances of each plugin in the "plugins" array', ->
        FooPlugin = Em.PipePlugin.extend()

        pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
          plugins: [FooPlugin, 'Em.PipePlugin'] 

        pipeline.get('_processors.firstObject').should.be.instanceof(FooPlugin)
        pipeline.get('_processors.lastObject').should.be.instanceof(Em.PipePlugin)


    describe '#_configureObserverMap()', ->

      FooPlugin = Em.PipePlugin.extend
        observes: ['name', 'date']

      BarPlugin = Em.PipePlugin.extend
        observes: ['name', 'age']

      it 'should create a map of observable properties -> plugin instances', ->
        # Setup of the pipeline 
        # We are manually configuring so that _configureObserverMap() isn't called
        pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin, {}
        pipeline.set('plugins', [FooPlugin, BarPlugin])
        pipeline._initPlugin(FooPlugin)
        pipeline._initPlugin(BarPlugin)
        
        # Run the configureObserverMap method
        pipeline._configureObserverMap()

        # Check to see if we get the expected results
        pipeline.get('_observerMap').get('name').should.be.instanceof(FooPlugin)
        pipeline.get('_observerMap').get('date').should.be.instanceof(FooPlugin)
        pipeline.get('_observerMap').get('age').should.be.instanceof(BarPlugin)

    describe '#_registerObservers()', ->
      it 'should register a single observer for each observable property', ->

        FooPlugin = Em.PipePlugin.extend
          observes: ['name', 'date']

        BarPlugin = Em.PipePlugin.extend
          observes: ['name', 'age']

        Book = Em.Object.extend
          name: null
          date: null
          age: null

        books = [
          Book.create(name: 'foo', date: 1921, age: 51)
          Book.create(name: 'andy', date: 1984, age: 11)
        ]

        # Manually creating to avoid out of the box init behavior
        pipeline = Em.ArrayProxy.createWithMixins(Em.ArrayPipelineMixin, content: books)
        pipeline.set('plugins', [FooPlugin, BarPlugin])
        pipeline._initPlugin(FooPlugin)
        pipeline._initPlugin(BarPlugin)
        pipeline._configureObserverMap()

        # Call our method
        pipeline._registerObservers()

        # Test to see that we have name / date observers registered
        pipeline.get('results').objectAt(0).observersForKey('name').length.should.equal(1)
        pipeline.get('results').objectAt(0).observersForKey('date').length.should.equal(1)
        pipeline.get('results').objectAt(0).observersForKey('age').length.should.equal(1)

    describe '#_processChanges()', ->
      it 'should trigger _recalculate() on the appropriate PipePlugin', ->
        ran = []

        FooPlugin = Em.PipePlugin.extend
          observes: ['name', 'date']
          _recalculate: ->
            ran.pushObject('pipe1')

        BarPlugin = Em.PipePlugin.extend
          observes: ['name', 'date']
          _recalculate: ->
            ran.pushObject('pipe2')

        Book = Em.Object.extend
          name: null
          date: null

        books = [
          Book.create(name: 'foo', date: 1921, age: 51)
          Book.create(name: 'andy', date: 1984, age: 11)
        ]

        # Create a pipeline to use
        pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin, 
          content: books
          plugins: [FooPlugin, BarPlugin]

        ran.should.deep.equal([])
        pipeline.set('firstObject.name', 'barrr')  
        ran.toArray().should.deep.equal(['pipe1', 'pipe2'])

  describe '#previousResults(plugin)', ->
    it 'should return back the results from the previous plugin that is passed in', ->
      Book = Em.Object.extend
        name: null
        date: null
        age: null

      FooPlugin = Em.PipePlugin.extend
        process: (inputArr) -> 
          inputArr.map (item) -> return 1

      BarPlugin = Em.PipePlugin.extend
        process: (inputArr) ->
          inputArr.map (item) -> return 2

      books = [
        Book.create(name: 'foo', date: 1921, age: 51)
        Book.create(name: 'andy', date: 1984, age: 11)
      ]

      pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin, 
        content: books
        plugins: [FooPlugin, BarPlugin, BarPlugin]

      # Trigger a calculation
      pipeline.get('results')

      # Do our test 
      lastPlugin = pipeline.get('_processors').objectAt(1)
      pipeline.previousResults(lastPlugin).should.deep.equal([1,1])