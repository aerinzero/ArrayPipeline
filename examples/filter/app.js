App = Ember.Application.create();


App.BookSelectionFilter = Em.PipePlugin.extend({
  observes: ['isSelected'],
  process: function(inputArr){
    return inputArr.filterProperty('isSelected', true);
  }
});

App.SortThing = Em.PipePlugin.extend({
  observes: ['title'],
  process: function(inputArr) {
    return inputArr.sort(function(o1,o2) {
      return Ember.compare(o1.get('title'), o2.get('title'));
    });
  }
});

App.Book = Em.Object.extend({
  title: null,
  isSelected: false  
});

App.ApplicationRoute = Em.Route.extend({
  model: function() {
    return [
      App.Book.create({title: "Andy"}),
      App.Book.create({title: "Mehul"}),
      App.Book.create({title: "Jeremy"}),
      App.Book.create({title: "Aaron"}),
      App.Book.create({title: "Christian"}),
      App.Book.create({title: "Tiny"}),
      App.Book.create({title: "Vasilis"}),
      App.Book.create({title: "Victor"}),
    ];
  }  
})

App.ApplicationController = Em.ArrayController.extend(Em.ArrayPipelineMixin,{
  plugins: [App.BookSelectionFilter, App.SortThing],

  toggleBook: function(book) {
    book.toggleProperty('isSelected');
  }
});