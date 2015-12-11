import Ember from 'ember';

export default Ember.Component.extend({

  classNameBindings: 'isDragging isDisabled:is-disabled'.w(),

  drop: function(event){
    var file;
    event.preventDefault();
    this.set('isDragging', false);

    // only 1 file for now
    file = event.dataTransfer.files[0];
    this.sendAction('fileInputChanged', file);

  },

   dragOver: function(event){
    // this is needed to avoid the default behaviour from the browser
    event.preventDefault();
  },

  dragEnter: function(event){
    event.preventDefault();
    this.set('isDragging', true);
  },

  dragLeave: function(event){
    event.preventDefault();
    this.set('isDragging', false);
  },




});
