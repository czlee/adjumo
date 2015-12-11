import Ember from 'ember';

export default Ember.Component.extend({

  tagName: 'tr',

  actions: {
    receivePanel: function(obj,ops) {
      console.log('receiving a panel');
    }
  },

  didInsertElement: function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      // Set default importance to the points
      var debate = this.get('debate');
      if (debate.get('importance') == null) {
        debate.set('importance', debate.get('points'));
      }
      this.$('[data-toggle="tooltip"]').tooltip();
    });

  },

});
