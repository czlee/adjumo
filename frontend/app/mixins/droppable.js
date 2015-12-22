import Ember from 'ember';

export default Ember.Mixin.create({

  dragOver: function(event){
    event.preventDefault(); // this is needed to avoid the default behaviour from the browser
  },

  dragEnter: function(event){
    event.preventDefault();
    this.$().addClass('dragging-over');
    return false;
  },

  dragLeave: function(event){
    event.preventDefault();
    this.$().removeClass('dragging-over');
    return false;
  },

  drop: function(event) {
    event.preventDefault();

    this.$().removeClass('dragging-over');
    $('.droppable-area').removeClass('dragging-active');
    $(".hover-key").show();

    return false;
  }

});
