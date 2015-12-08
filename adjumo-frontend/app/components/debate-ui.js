import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  actions: {
    receivePanel: function(obj,ops) {
      console.log('receiving a panel');
    }
  },

  didInsertElement: function() {
    var debate = this.get('debate');
    if (debate.get('importance') == null) {
      debate.set('importance', debate.get('points'));
    }

  }

});
