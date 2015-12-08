import DS from 'ember-data';

export default DS.Model.extend({

  name: DS.attr('string'),
  adjudicator_id: DS.attr('number'),
  institutions: DS.hasMany('institution'),
  locked: DS.attr('bool', { defaultValue: false }),
  rating: DS.attr('number'),
  region: DS.attr('string'),
  gender: DS.attr('number'),

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

  // strikedAdjudicators: DS.hasMany('adjudicator'),
  // strikedTeams: DS.hasMany('team'),

  // pastAdjudicatorIDs: DS.attr('adjudicator'),
  // pastTeamIDs: DS.attr('team'),

  panel: DS.belongsTo('panel')

});
