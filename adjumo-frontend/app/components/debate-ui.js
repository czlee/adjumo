import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  actions: {

    receivePanel: function(obj,ops) {
      console.log('receiving a panel');
    }

  }

});
