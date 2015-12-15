import DS from 'ember-data';

export default DS.Model.extend({

  name: DS.attr('string'),
  institution: DS.belongsTo('institution'),
  language: DS.attr('string'),
  gender: DS.attr('number'),

});
