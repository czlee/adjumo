import DS from 'ember-data';

export default DS.Model.extend({

  panels: DS.hasMany('panelallocations', { async: false }),
  active: DS.attr('bool', { default: true }),

});
