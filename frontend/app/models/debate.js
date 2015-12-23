import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({

  points: DS.attr('number', { default: "" }),
  venue: DS.attr('string', { default: "" }),
  weight: DS.attr('number'),
  importance: DS.attr('number'),

  panels: DS.hasMany('panelallocations'),
  teams: DS.hasMany('team'),

  bans: DS.hasMany('adjudicator', { inverse: 'bannedFrom' }),
  locks: DS.hasMany('adjudicator', { inverse: 'lockedTo' }),

  weightRounded: Ember.computed('weight', function() {
    return Math.round(this.get('weight') * 10) / 10; // normalise to 1-9 like adjs
  }),

  rankingClass: Ember.computed('importance', function() {
    return Math.round(this.get('importance'));
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
