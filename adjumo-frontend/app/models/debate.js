import DS from 'ember-data';

export default DS.Model.extend({

  //id: DS.attr('number'),
  //points: DS.attr('number'),
  //venue: DS.attr('string'),
  weight: DS.attr('number'),
  importance: DS.attr('number'),

  panels: DS.hasMany('panelallocations'),
  teams: DS.hasMany('team'),

  weightRounded: Ember.computed('weight', function() {
    return Math.round(this.get('weight') * 10) / 10; // normalise to 1-9 like adjs
  }),

  rankingClass: Ember.computed('importance', function() {
    return Math.round(this.get('importance') * 0.9) / 1;
  }),

  og: Ember.computed('teams', function() {
    return this.get('teams').objectAt(0);
  }),

  oo: Ember.computed('teams', function() {
    return this.get('teams').objectAt(1);
  }),

  cg: Ember.computed('teams', function() {
    return this.get('teams').objectAt(2);
  }),

  co: Ember.computed('teams', function() {
    return this.get('teams').objectAt(3);
  }),



});
