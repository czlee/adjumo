import Ember from 'ember';
import AdjorTeam from '../mixins/adjorteam';

export default Ember.Mixin.create(AdjorTeam, {

  dragStart: function(event) {
    //console.log("dragStart");
    $('.droppable-area').addClass('dragging-active');
  },

  dragEnd: function(event) {
    //console.log("dragEnd");
    $('.droppable-area').removeClass('dragging-active');
  },

});
