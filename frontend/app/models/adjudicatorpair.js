import DS from 'ember-data';

export default DS.Model.extend({

  adj1: DS.belongsTo('adjudicator', {async: true}),
  adj2: DS.belongsTo('adjudicator', {async: true}),

});