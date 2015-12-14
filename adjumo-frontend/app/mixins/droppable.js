import Ember from 'ember';

export default Ember.Mixin.create({

  dragOver: function(event){
    event.preventDefault(); // this is needed to avoid the default behaviour from the browser
  },

  dragEnter: function(event){
    event.preventDefault();
    return false;
  },

  dragLeave: function(event){
    event.preventDefault();
    return false;
  },

});
