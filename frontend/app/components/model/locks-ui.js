import Ember from 'ember';
import DroppableMixin from '../../mixins/droppable';

// This is a copy of bans-ui. TODO: refactor/abstract

export default Ember.Component.extend(DroppableMixin, {

  tagName: 'td',
  classNames: ['debate-panel', 'debate-locks', 'preallocation', 'droppable-area'],

  drop: function(event) {

    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);

    this.get('debate').get('locks').pushObject(droppedAdj);

    // If being locked to somewhere then no need to be banned elsewhere so remove them
    var previousBans = droppedAdj.get('bannedFrom');
    previousBans.toArray().forEach(function(ban) {
      previousBans.removeObject(ban);
    });

    return this._super(event);

  }

});