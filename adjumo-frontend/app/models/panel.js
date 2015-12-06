import DS from 'ember-data';

export default DS.Model.extend({

  adjudicators: DS.hasMany('adjudicator'),

  panel: DS.belongsTo('debate'),

});
