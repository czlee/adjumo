import DS from 'ember-data';

export default DS.Model.extend({

  groupAdjudicators: DS.hasMany('adjudicator', { inverse: 'group' }),

});
