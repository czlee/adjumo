import Ember from 'ember';

export default Ember.Mixin.create({

  dragOver: function(event){
    event.preventDefault(); // this is needed to avoid the default behaviour from the browser
  },

  dragEnter: function(event){
    event.preventDefault();
    this.$('.droppable-area').addClass('dragging-over');
    return false;
  },

  dragLeave: function(event){
    event.preventDefault();
    this.$('.droppable-area').removeClass('dragging-over');
    return false;
  },

  drop: function(event) {
    event.preventDefault();
    this.$('.droppable-area').removeClass('dragging-over');
    $('.droppable-area').removeClass('dragging-active');

    // When dropping it can sometimes not stop the hovering effects
    $(".institution-conflict").removeClass("institution-conflict");
    $(".team-conflict").removeClass("team-conflict");
    $(".adj-conflict").removeClass("adj-conflict");
    $("#conflictsKey").hide();
    $(".hover-key").show();


    return false;
  }

});
