import DS from 'ember-data';

export default DS.Model.extend({

  name: DS.attr('string'),
  region: DS.attr('number'),
  institution: DS.belongsTo('institution'),
  language: DS.attr('string'),
  gender: DS.attr('number'),

});
