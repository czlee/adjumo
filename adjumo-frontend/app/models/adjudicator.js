import DS from 'ember-data';

export default DS.Model.extend({

  name: DS.attr('string'),
  adjudicator_id: DS.attr('number'),
  institutions: DS.hasMany('institution'),

  rating: DS.attr('number'),

  // strikedAdjudicators: DS.hasMany('adjudicator'),
  // strikedTeams: DS.hasMany('team'),

  // pastAdjudicatorIDs: DS.attr('adjudicator'),
  // pastTeamIDs: DS.attr('team'),

  // panel: DS.belongsTo('panel')

});
