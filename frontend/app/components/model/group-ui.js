import Ember from 'ember';
import DroppableMixin from '../../mixins/droppable';

export default Ember.Component.extend(DroppableMixin, {

  classNames: ['droppable-area adj-group'],
  classNameBindings: ['id'],

  id: function() {
    return 'group-' + String(this.get('group').get('id'));
  }.property('group'),

  drop: function(event) {

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);

    droppedAdj.set('group', this.get('group'));

    this.sendAction('checkWhetherToAddNewGroups');

    return this._super(event);

  }

});
