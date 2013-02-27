###
Figure out how to get these into a separate helper
###
require './test_helper.coffee'

beforeEach ->
  @sourceArray = Em.A(['one','two','three'])
  
  @pipeline = Em.ArrayProxy.createWithMixins Ember.ArrayPipelineMixin,
    content: @sourceArray

describe 'Array Pipeline Setup', ->

  it 'should have results that match the content array', ->
    @sourceArray.should.equal @pipeline.get('results')

  it 'should work', ->
    1.should.equal 1
