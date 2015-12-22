import DS from 'ember-data';

export default DS.Model.extend({

  rounds: DS.attr(), // Array of integers

  adj1: DS.belongsTo('adjudicator', {async: true}),
  adj2: DS.belongsTo('adjudicator', {async: true}),

  active: DS.attr('bool', { default: false }) // If the conflict is active when panel hovering

});
