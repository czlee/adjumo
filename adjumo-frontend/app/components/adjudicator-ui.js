import Ember from 'ember';

export default Ember.Component.extend({

  locked: Ember.computed.alias('adj.locked'),

  actions: {

    drop: function(obj,ops) {
      console.log('WTF');
    },

    lockAdj: function() {
      this.get('adj').set('locked', true);
      // this.sendAction('setAdjLocked', this.get('adj')); sends an action the route which can then change the store
    },
    unlockAdj: function() {
      this.get('adj').set('locked', false);
      // this.sendAction('setAdjUnlocked', this.get('adj'));sends an action the route which can then change the store
    }

  },

  didInsertElement: function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      this.$('[data-toggle="tooltip"]').tooltip();
    });
  }

});
