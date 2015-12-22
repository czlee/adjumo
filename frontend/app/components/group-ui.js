import Ember from 'ember';
import DroppableMixin from '../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  classNames: ['droppable-area adj-group'],

  drop: function(event) {

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);

    console.log(this.get('group'));
    droppedAdj.set('group', this.get('group'));

    return this._super(event);

  }

});
