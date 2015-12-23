import Ember from 'ember';
import DroppableMixin from '../../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  tagName: 'td',
  classNames: ['debate-panel', 'debate-bans', 'preallocation', 'droppable-area'],

  drop: function(event) {

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);

    this.get('debate').get('bans').pushObject(droppedAdj);
    this.get('debate').get('locks').removeObject(droppedAdj);

    return this._super(event);

  }

});