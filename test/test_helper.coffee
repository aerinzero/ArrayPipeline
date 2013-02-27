# Chai setup
global.chai = require 'chai'
chai.should()

# Fake window setup
jsdom = require('jsdom').jsdom
global.document = jsdom('<html><head></head><body></body></html>')
global.window = document.createWindow()

# Library dependencies
global.jQuery = global.$ = require 'jquery'
global.Handlebars = require('../lib/handlebars-1.0-rc.3').Handlebars
global.Ember = global.Em = require('../lib/ember-1.0.0-rc.1').Ember