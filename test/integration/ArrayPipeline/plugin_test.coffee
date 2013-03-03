require '../../test_helper.coffee'

###
# Test setup
###
Book = Em.Object.extend
  isSelected: false
  name: null

FilterPipe = Em.PipePlugin.extend
  observes: ['isSelected']
  process: (inputArr) -> inputArr.filterProperty('isSelected', true)

beforeEach ->
  @books = [
    Book.create(name: "foo", isSelected: false)
    Book.create(name: "foo", isSelected: true)
  ]

###
# Tests
###
describe 'Plugin: ArrayPipeline', ->

  it 'instantiates configured plugins', ->
    pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
      plugins: [FilterPipe]

    expect(pipeline.get('_processors.firstObject')).to.be.instanceof(FilterPipe)

  it 'updates the results array with plugin-processed results', ->
    pipeline = Em.ArrayProxy.createWithMixins Em.ArrayPipelineMixin,
      content: @books
      plugins: [FilterPipe]

    results = pipeline.get('results')

    results.get('length').should.equal(1)
    results.get('firstObject').should.equal @books[1]