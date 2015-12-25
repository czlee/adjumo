import DS from 'ember-data';

export default DS.Model.extend({

  adj1: DS.belongsTo('adjudicator', {async: true}),
  adj2: DS.belongsTo('adjudicator', {async: true}),

  hoverActive: DS.attr('bool', { default: false }), // If the conflict is active when panel hovering
  panelActive: DS.attr('bool', { default: false }) // If the conflict is active when panel hovering

});
