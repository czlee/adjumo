import DS from 'ember-data';

export default DS.Model.extend({

  debate_id: DS.attr('number'),
  points: DS.attr('number'),
  venue: DS.attr('string'),
  importance: DS.attr('number', { defaultValue: 1 }),

  panel: DS.belongsTo('panel'),

  og: DS.belongsTo('team'),
  oo: DS.belongsTo('team'),
  cg: DS.belongsTo('team'),
  co: DS.belongsTo('team')

});
