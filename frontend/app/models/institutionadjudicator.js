import DS from 'ember-data';

export default DS.Model.extend({

  adjudicator: DS.belongsTo('adjudicator', {async: true}),
  institution: DS.belongsTo('institution', {async: true}),

  hoverActive: DS.attr('bool', { default: false }), // If the conflict is active when panel hovering
  panelActive: DS.attr('bool', { default: false }) // If the conflict is active when panel hovering

});
