import Ember from 'ember';

export default Ember.Mixin.create({

  dragStart: function(event) {
    console.log("dragStart");
    $('.droppable-area').addClass('dragging-active');
  },

  dragEnd: function(event) {
    console.log("dragEnd");
    $('.droppable-area').removeClass('dragging-active');
  },

  drop: function(event) {
    console.log("drop");
  },

});
