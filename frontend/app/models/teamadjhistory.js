import DS from 'ember-data';

export default DS.Model.extend({

  rounds: DS.attr(), // Array of integers

  team: DS.belongsTo('team'),
  adjudicator: DS.belongsTo('adjudicator'),

  hoverActive: DS.attr('bool', { default: false }), // If the conflict is active when panel hovering
  panelActive: DS.attr('bool', { default: false }), // If the conflict is active when panel hovering

  roundInfo: Ember.inject.service('round-info'),

});
