# ArrayPipeline 

**Note: Core functionality is still being implemented.  Please look at the [Issues list](https://github.com/Mochaleaf/ArrayPipeline/issues) to see what is actively being worked on.**

# What is ArrayPipeline?  

## Ember.ArrayPipelineMixin 
**ArrayPipelineMixin** is an Ember Mixin that can be used to perform a set of piped operations on an Array via a series of ordered **Ember.PipePlugin** subclasses.  This class is the main engine for chaining our work together.  It is not intended to be subclassed or overridden.

Each element in the original **content** Array will be processed in order by the **plugins** defined on the **ArrayPipeline**.  Each individual plugin will be responsible for doing some sort of processing on an array of object's passed in to the plugin, and will hand off it's results to the next plugin.


## Ember.PipePlugin
**PipePlugin** is a base class intended to be subclassed to implement a **process** method *(used to process each element of an array)* and a list of **observes** properties *(used to recalculate changes)*.  

Each **PipePlugin** will register observation changes for the elements contained in the original **content** array if it is the FirstResponder for that observation.  

# The Typical Book Example  
Let's pretend that we have a list of ```Books``` with a ```name``` property.  On the books, we want to filter out ```names``` that begin with the letter *a*, and then we want to sort the results of the filter alphabetically.  

Here's the code we would write to make this work:

```coffee
  # Our Model
  App.Book = DS.Model.extend
    name: DS.attr('string')
    age: DS.attr('number')

  # Our ArrayController of Books
  App.BookController = Em.ArrayController.extend Em.ArrayPipelineMixin,
    plugins: [BookFilter, BookSort]

    # This will be set by our UI
    selectedLetter: null

  # Our Filter Pipe
  BookFilter = Em.PipePlugin.extend
    # Properties we want to observe
    observes: ['name', 'controller.selectedLetter']

    # Our method for operating on our array of relevant objects 
    process: (inputArr) ->
      # We have no processing to do if a letter is not selected, but we still return the inputArr
      letter = @get('controller.selectedLetter')
      return inputArr if !letter?

      # This will return a filtered version of our inputArr if we do have a letter to use
      regex = new RegExp("^#{letter}", 'i')
      inputArr.filter (item) ->
        return false if (typeof item.get('name') != 'string')
        return item.match(regex)

  # Our Sort Pipe
  BookSort = Em.PipePlugin.extend
    observes: ['name', 'controller.selectedLetter', 'age']
    process: (inputArr) ->
      inputArr.sort (obj1, obj2) -> 
        result = Em.compare(obj1.get('name'), obj2.get('name'))
        result = Em.compare(obj1.get('age'), obj2.get('age')) if result == 0
        return result
``` 

And in our template, we utilize **results** to get at the output of the Pipeline:

```mustache
  <ul>
  {{#each book in results}}
    <ol>{{book.name}}</ol>
  {{/each}}
  </ul>
```

Some important things to point out with this example.  When a book's name changes, the following will happen:

1. ```BookFilter``` plugin will want to recompute changes
2. The ```BookFilter``` plugin will obtain the result set from the previous plugin.  (In this case, it's the first plugin, so it will obtain the content from the ArrayController)
3. The ```BookFilter``` will execute it's ```process``` method and send the results to the next plugin in the Pipeline.

If we were to change the ```age``` property on a book:

1. ```BookSort``` plugin will want to recompute changes
2. The ```BookSort``` plugin will go to ```BookFilter``` to obtain it's last output array.  It will use that data to recompute the sorting for ```BookSort```.
3. The ```process``` method will run and sent the results to the next plugin in the Pipeline.  (In this case, it will be set as the results on the Pipeline). 


# What Works
  * Chaining plugins together

# What Doesn't Work Yet
  * Observation firing *(currently WIP and will be pushed to wip branch)*
  * Adding / Removing objects from array
  * Support for side-operations

# The Flow
![Image](../master/doc/ArrayPipelineFlow.png?raw=true)

# Build Environment & Contributing
  Please see the [CONTRIBUTING.md](https://github.com/Mochaleaf/ArrayPipeline/blob/master/CONTRIBUTING.md) for info on how to lend a hand, or for more information on the build environment!

# License
See [LICENSE.txt](../master/LICENSE.txt?raw=true) for more info.