require '../test_helper.coffee'

###
# Test Classes
###

firedPlugins = []
pipeline = {}

Book = Em.Object.extend
  isSelected: false
  name: null
  year: null

Pipe1 = Em.PipePlugin.extend
  observes: ['isSelected']
  process: (inputArr) ->
    firedPlugins.pushObject 'pipe1'
    return inputArr

Pipe2 = Em.PipePlugin.extend
  observes: ['isSelected', 'name']
  process: (inputArr) ->
    firedPlugins.pushObject 'pipe2'
    return inputArr

Pipe3 = Em.PipePlugin.extend
  observes: ['isSelected', 'name', 'year']
  process: (inputArr) ->
    firedPlugins.pushObject 'pipe3'
    return inputArr

Pipe4 = Em.PipePlugin.extend
  observes: ['controller.selectedBook']
  process: (inputArr) ->
    firedPlugins.pushObject 'pipe4'
    return inputArr

beforeEach ->
  firedPlugins = []

  books = [
    Book.create(name: "andy", isSelected: false, year: 2012)
    Book.create(name: "tom", isSelected: true, year: 2013)
    Book.create(name: "huda", isSelected: false, year: 2011)
    Book.create(name: "dgeb", isSelected: true, year: 2010)
    Book.create(name: "trek", isSelected: true, year: 2010)
    Book.create(name: "ebryn", isSelected: false, year: 2011)
    Book.create(name: "luke", isSelected: true, year: 2010)
    Book.create(name: "paul", isSelected: true, year: 2010)
    Book.create(name: "alex", isSelected: false, year: 2010)
    Book.create(name: "joey", isSelected: true, year: 2011)
  ]

  pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
    content: books
    plugins: [Pipe1, Pipe2, Pipe3]


###
# Tests
###

describe 'Observers:', ->

  describe 'PipePlugin', ->
    it 'registers observers for each property in "observes" if it is the firstResponder', ->
      # Our fired list should start at 0
      firedPlugins.get('length').should.equal(0)

      # After getting results, our fired list should be at 3
      pipeline.get('results')
      firedPlugins.get('length').should.equal(3)

      # When we change the name, pipe2 and pipe3 should run
      books = pipeline.get('content')
      books.get('firstObject').set('name', 'Mooooo')
      firedPlugins.toArray().should.deep.equal(['pipe1', 'pipe2', 'pipe3', 'pipe2', 'pipe3'])

      # When we change the year, only pipe3 should run
      books.get('firstObject').set('year', 1999)
      firedPlugins.toArray().should.deep.equal(['pipe1', 'pipe2', 'pipe3', 'pipe2', 'pipe3', 'pipe3'])

    it 'registers observers destined for our controller', ->
      # setup
      books = [Book.create(name: "andy", isSelected: false, year: 2012)]
      pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
        content: books
        plugins: [Pipe4]
        selectedBook: null

      # test initial state
      firedPlugins.get('length').should.equal(0)

      # set our book on our controller
      book = books.get('firstObject')
      pipeline.set('selectedBook', book)

      # pipe plugin should have refired
      firedPlugins.toArray().should.deep.equal(['pipe4'])

    it 'is fired when arrayContent is added', ->
      pipeline.get('results')

      # Our fired list should start at 3
      firedPlugins.get('length').should.equal(3)

      newBook = Book.create(name:'Andy', isSelected: false, year: 2014)
      pipeline.get('content').pushObject(newBook)

      # Our fired list should be at 6
      firedPlugins.get('length').should.equal(6)

  describe 'ArrayPipeline', ->
    it 'updates the results set when you change the backing array content', ->
      arrayOne = [Book.create(name:'foo')]
      arrayTwo = [Book.create(name:'bar')]

      pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
        content: arrayOne
        plugins: []

      pipeline.get('results').should.deep.equal(arrayOne)

      pipeline.set('content', arrayTwo)
      pipeline.get('results').should.deep.equal(arrayTwo)

    it 'unregisters observers from the previous backing array content when changed', ->
      arrayOne = [Book.create(name:'foo')]
      arrayTwo = [Book.create(name:'foo')]

      Plugin = Em.PipePlugin.extend
        observes: ['name']
        process: (inputArr) -> return inputArr

      pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
        content: arrayOne
        plugins: [Plugin]

      Ember.observersFor(arrayOne.get('firstObject'), 'name').length.should.equal(1)

      pipeline.set('content', arrayTwo)
      Ember.observersFor(arrayOne.get('firstObject'), 'name').length.should.equal(0)
