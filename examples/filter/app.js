App = Ember.Application.create();


App.BookSelectionFilter = Em.PipePlugin.extend({
  observes: ['isSelected'],
  process: function(inputArr){
    return inputArr.filterProperty('isSelected', true);
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
  plugins: [App.BookSelectionFilter],

  toggleBook: function(book) {
    book.toggleProperty('isSelected');
  }
});