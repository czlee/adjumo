import DS from 'ember-data';

export default DS.Model.extend({

  rounds: DS.attr(),

  seenTeam: DS.belongsTo('team', { async: true }),
  seenAdjudicator: DS.belongsTo('adjudicator', { async: true }),

});
