import DS from 'ember-data';

export default DS.Model.extend({

  rounds: DS.attr(), // Array of integers

  team: DS.belongsTo('team'),
  adjudicator: DS.belongsTo('adjudicator'),

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
    return intensity;
  }),

});
