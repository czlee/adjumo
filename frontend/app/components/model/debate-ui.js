import Ember from 'ember';

export default Ember.Component.extend({

  classNameBindings: ['id'],
  tagName: 'tr',

  id: function(){
    return 'debate-' + String(this.get('debate').get('id'));
  }.property('id'),


  actions: {
    // receivePanel: function() {
    //   console.log('receiving a panel');
    // }
  },

  didInsertElement: function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      // Set default importance to the points
      var debate = this.get('debate');
      if (debate.get('importance') == null) {
        debate.set('importance', Math.round(debate.get('weight')));
      }
      this.$('[data-toggle="tooltip"]').tooltip();
    });

  },

});
