import DS from 'ember-data';

export default DS.Model.extend({

  rounds: DS.attr(), // Array of integers

  adj1: DS.belongsTo('adjudicator', {async: true}),
  adj2: DS.belongsTo('adjudicator', {async: true}),

  hoverActive: DS.attr('bool', { default: false }), // If the conflict is active when panel hovering
  panelActive: DS.attr('bool', { default: false }), // If the conflict is active when panel hovering

  roundInfo: Ember.inject.service('round-info'),

  historyIntensity: Ember.computed('rounds', 'roundInfo', function() {

    var currentRound = this.get('roundInfo').get('sequence');
    var seenRounds = this.get('rounds');
    var intensity = 0;
    seenRounds.forEach(function(seenRound) {
      intensity += 1 / (currentRound - Number(seenRound));
    });

    intensity = Math.round(intensity * 5); // Round to fit roughly 1-6 for CSS class
    if (intensity > 5) {
      intensity = 6;
    }

    return intensity;
  }),

});
