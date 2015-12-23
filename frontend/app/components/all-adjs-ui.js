import Ember from 'ember';
import AdjHolderMixing from '../mixins/adjholder';

export default Ember.Component.extend(AdjHolderMixing, {

  classNames: ['all-adjs-panel'],

  typeClass: '.all-adjs-panel', // For resizing
  minHeight: 45,
  maxHeight: 400,

  drop: function(event){

    var fromType = event.originalEvent.dataTransfer.getData('fromType');
    var droppedAdjID = event.originalEvent.dataTransfer.getData('AdjID');
    var droppedAdj = this.get('adjudicators').findBy('id', droppedAdjID);

    if (fromType === 'locks') {
      // If coming from a lock just remove it (can only be locked to one thing at a time)
      droppedAdj.set('lockedTo', null);
    }
    else if (fromType === 'bans')
    {
      // If coming from a ban need to remove just the originating ban
      var debateToUnBanFromID = event.originalEvent.dataTransfer.getData('DebateID');
      droppedAdj.get('bannedFrom').forEach(function(ban) {
        if (ban.get('id') === debateToUnBanFromID) {
          droppedAdj.get('bannedFrom').removeObject(ban);
        }
      });
    }
    return this._super(event);

  },

});
