import DS from 'ember-data';

export default DS.Model.extend({

  groupAadjudicators: DS.hasMany('adjudicator', { inverse: 'group' }),

});
