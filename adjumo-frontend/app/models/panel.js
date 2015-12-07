import DS from 'ember-data';

export default DS.Model.extend({

  chair: DS.belongsTo('adjudicator'),
  panellists: DS.hasMany('adjudicator'),
  trainees: DS.hasMany('adjudicator'),

  debate: DS.belongsTo('debate'),

});
