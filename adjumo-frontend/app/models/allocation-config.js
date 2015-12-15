import DS from 'ember-data';

export default DS.Model.extend({

  quality: DS.attr('number', { defaultValue: 5 } ),
  regional: DS.attr('number', { defaultValue: 5 } ),
  language: DS.attr('number', { defaultValue: 5 } ),
  gender: DS.attr('number', { defaultValue: 5 } ),
  teamHistory: DS.attr('number', { defaultValue: 5 } ),
  adjHistory: DS.attr('number', { defaultValue: 5 } ),
  teamConflict: DS.attr('number', { defaultValue: 5 } ),
  adjConflict: DS.attr('number', { defaultValue: 5 } ),

});
