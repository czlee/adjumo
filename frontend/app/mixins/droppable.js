import Ember from 'ember';

export default Ember.Mixin.create({

  dragCounter: 0, // This is used to prevent hover over child elements breaking the hover highlight

  dragOver: function(event){
    event.preventDefault(); // this is needed to avoid the default behaviour from the browser
  },

  dragEnter: function(event){
    event.preventDefault();

    this.$().addClass('dragging-over');
    this.dragCounter++;

    return false;
  },

  dragLeave: function(event){
    event.preventDefault();

    this.dragCounter--;
    if (this.dragCounter === 0) {
      this.$().removeClass('dragging-over');
    }

    return false;
  },

  drop: function(event) {
    event.preventDefault();

    this.$().removeClass('dragging-over');
    this.dragCounter = 0;
    $('.droppable-area').removeClass('dragging-active');
    $(".hover-key").show();

    return false;
  }

});
