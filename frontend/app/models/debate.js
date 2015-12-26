import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({

  venue: DS.attr('string', { default: "" }),
  weight: DS.attr('number'),
  importanceModifier: 0,

  panels: DS.hasMany('panelallocations'),
  teams: DS.hasMany('team'),

  bans: DS.hasMany('adjudicator', { inverse: 'bannedFrom' }),
  locks: DS.hasMany('adjudicator', { inverse: 'lockedTo' }),

  genderdeficit: DS.attr('number'),
  languagedeficit: DS.attr('number'),
  qualitydeficit: DS.attr('number'),
  regionaldeficit: DS.attr('number'),

  points: Ember.computed('teams', function() {
    var teamPoints = this.get('teams').mapBy('points');
    var sum = teamPoints.reduce(function(a, b) { return a + b; });
    var avg = sum / teamPoints.length;
    return Math.round(avg * 10) / 10; // normalise to 1-9 like adjs
  }),

  importance: Ember.computed('weight', 'importanceModifier', function() {
    var importance = Number(this.get('weight')) + Number(this.get('importanceModifier'));
    return Math.round(importance * 10) / 10;
  }),

  importanceClass: Ember.computed('importance', function() {
    return Math.round((this.get('importance') + 5) / 20 * 10);
  }),

  weightRounded: Ember.computed('weight', function() {
    return Math.round(this.get('weight') * 10) / 10; // normalise to 1-9 like adjs
  }),

});
