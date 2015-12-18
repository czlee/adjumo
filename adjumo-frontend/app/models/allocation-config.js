import DS from 'ember-data';

export default DS.Model.extend({

  quality: DS.attr('number', { defaultValue: 5 } ),
  regional: DS.attr('number', { defaultValue: 5 } ),
  language: DS.attr('number', { defaultValue: 5 } ),
  gender: DS.attr('number', { defaultValue: 5 } ),
  teamhistory: DS.attr('number', { defaultValue: 5 } ),
  adjhistory: DS.attr('number', { defaultValue: 5 } ),
  teamconflict: DS.attr('number', { defaultValue: 5 } ),
  adjconflict: DS.attr('number', { defaultValue: 5 } ),

});
