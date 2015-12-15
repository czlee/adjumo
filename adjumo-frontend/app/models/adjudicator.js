import DS from 'ember-data';

export default DS.Model.extend({

  name: DS.attr('string'),
  institutions: DS.hasMany('institution'),

  locked: DS.attr('bool', { defaultValue: false }),
  ranking: DS.attr('number'),
  gender: DS.attr('number'),
  language: DS.attr('number'),

  // strikedAdjudicators: DS.hasMany('adjudicator', { inverse: null }),
  strikedTeams: DS.hasMany('team', { inverse: null }),
  // pastAdjudicators: DS.hasMany('adjudicator', { inverse: null }),
  // pastTeams: DS.hasMany('team', { inverse: null }),

  panel: DS.belongsTo('panel', { inverse: null }),

  short_name: Ember.computed('name', function() {
    var words = this.get('name').split(" ");
    var short_name = words[0] + " " + words[1][0];
    return short_name;
  }),

  regions: Ember.computed('institutions', function() {
    var regions = new Array();
    this.get('institutions').get('content').forEach(function(institution) {
      regions.push(institution.get('region'));
    });
    return regions;
  }),

  region_classes: Ember.computed('institutions', function() {
    var regionClasses = new Array();
    this.get('regions').forEach(function(region) {
      regionClasses.push('region-' + region.get('id') + ' ');
    });
    return regionClasses;
  }),

  get_ranking: function() {
    var ranking_word = "";
    if (this.get('ranking') <= 3) {
      ranking_word = "T";
      if (this.get('ranking') == 1) {
        ranking_word += "-";
      }
      else if (this.get('ranking') == 3) {
        ranking_word += "+";
      }
    } else if (this.get('ranking') <= 6) {
      ranking_word = "P";
      if (this.get('ranking') == 4) {
        ranking_word += "-";
      }
      else if (this.get('ranking') == 6) {
        ranking_word += "+";
      }
    } else if (this.get('ranking') <= 9) {
      ranking_word = "C";
      if (this.get('ranking') == 7) {
        ranking_word += "-";
      }
      else if (this.get('ranking') == 9) {
        ranking_word += "+";
      }
    }
    return ranking_word;
  }.property('ranking'),

});
