import DS from 'ember-data';

export default DS.Model.extend({

  team: DS.belongsTo('team', {async: true}),
  adjudicator: DS.belongsTo('adjudicator', {async: true}),

});
