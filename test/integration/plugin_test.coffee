require '../test_helper.coffee'

###
# Test setup
###
Book = Em.Object.extend
  isSelected: false
  name: null

SelectedPipe = Em.PipePlugin.extend
  observes: ['isSelected']
  process: (inputArr) -> inputArr.filterProperty('isSelected', true)

SortPipe = Em.PipePlugin.extend
  observes: ['name']
  process: (inputArr) ->
    inputArr.sort (obj1, obj2) -> Em.compare(obj1.get('name'), obj2.get('name'))

PagePipe = Em.PipePlugin.extend
  observes: ['controller.page']
  pageBinding: 'controller.page'
  numPerPage: 3
  process: (inputArr) ->
    endIdx = @get('page') * @get('numPerPage')
    inputArr.slice(0,endIdx)

beforeEach ->
  @books = [
    Book.create(name: "andy", isSelected: false)
    Book.create(name: "tom", isSelected: true)
    Book.create(name: "huda", isSelected: false)
    Book.create(name: "dgeb", isSelected: true)
    Book.create(name: "trek", isSelected: true)
    Book.create(name: "ebryn", isSelected: false)
    Book.create(name: "luke", isSelected: true)
    Book.create(name: "paul", isSelected: true)
    Book.create(name: "alex", isSelected: false)
    Book.create(name: "joey", isSelected: true)
  ]

###
# Tests
###
describe 'Plugin: ArrayPipeline', ->

  it 'instantiates configured plugins', ->
    pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
      plugins: [SelectedPipe]

    expect(pipeline.get('_processors.firstObject')).to.be.instanceof(SelectedPipe)

  it 'updates the results array with plugin-processed results', ->
    pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
      content: @books
      plugins: [SelectedPipe]

    results = pipeline.get('results')

    results.get('length').should.equal(6)
    results.get('firstObject').should.equal @books[1]

  describe 'chained plugin results', ->

    it 'filters by selection then sorts', ->
      pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
        content: @books
        plugins: [SelectedPipe, SortPipe]

      results = pipeline.get('results')

      results.get('length').should.equal(6)
      results.get('firstObject.name').should.equal 'dgeb'
      results.get('lastObject.name').should.equal 'trek'

    # it 'filters by selection then sorts then paginates', ->
    #   pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
    #     content: @books
    #     page: 1
    #     plugins: [SelectedPipe, SortPipe, PagePipe]

    #   results = pipeline.get('results')

    #   results.get('length').should.equal(3)
    #   results.get('lastObject.name').should.equal 'luke'

    #   pipeline.set('page', 2)
    #   results.get('length').should.equal(6)
    #   results.get('lastObject.name').should.equal 'trek'