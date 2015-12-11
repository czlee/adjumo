import DS from 'ember-data';

export default DS.Model.extend({

  name: DS.attr('string'),
  institutions: DS.hasMany('institution'),

  locked: DS.attr('bool', { defaultValue: false }),
  rating: DS.attr('number'),
  gender: DS.attr('number'),

  // strikedAdjudicators: DS.hasMany('adjudicator', { inverse: null }),
  strikedTeams: DS.hasMany('team', { inverse: null }),
  // pastAdjudicators: DS.hasMany('adjudicator', { inverse: null }),
  // pastTeams: DS.hasMany('team', { inverse: null }),

  panel: DS.belongsTo('panel', { inverse: null }),

  is_allocated: Ember.computed('panel', function() {
    var panel = this.get('panel');
    console.log(panel);
    if (this.panel) {
      return true;
    } else {
      return false;
    };
  }),

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

  get_rating: function() {
    var rating_word = "";
    if (this.get('rating') <= 3) {
      rating_word = "T";
      if (this.get('rating') == 1) {
        rating_word += "-";
      }
      else if (this.get('rating') == 3) {
        rating_word += "+";
      }
    } else if (this.get('rating') <= 6) {
      rating_word = "P";
      if (this.get('rating') == 4) {
        rating_word += "-";
      }
      else if (this.get('rating') == 6) {
        rating_word += "+";
      }
    } else if (this.get('rating') <= 9) {
      rating_word = "C";
      if (this.get('rating') == 7) {
        rating_word += "-";
      }
      else if (this.get('rating') == 9) {
        rating_word += "+";
      }
    }
    return rating_word;
  }.property('rating'),

});
