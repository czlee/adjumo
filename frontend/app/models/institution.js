import DS from 'ember-data';

export default DS.Model.extend({

  name: DS.attr('string'),
  code: DS.attr('string'),
  teams: DS.hasMany('team'),
  adjudicators: DS.hasMany('adjudicator'),
  region: DS.belongsTo('region'),

  hoverActive: DS.attr('bool', { default: false }), // If the conflict is active when panel hovering

});
