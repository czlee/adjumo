import DS from 'ember-data';

export default DS.Model.extend({

  chair: DS.belongsTo('adjudicator', { inverse: null }),
  panellists: DS.hasMany('adjudicator', { inverse: null }),
  trainees: DS.hasMany('adjudicator', { inverse: null }),

  debate: DS.belongsTo('debate'),

});

