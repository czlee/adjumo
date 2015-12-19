import DS from 'ember-data';
import DebateableMixin from '../mixins/debateable';

export default DS.Model.extend(DebateableMixin, {

  // Note: gets its base attributes from the debateable mixin

  regions: DS.attr(), // Leave blank so it will accept an array
  locked: DS.attr('bool', { defaultValue: false }),
  ranking: DS.attr('number'),
  panel: DS.belongsTo('panelallocation', { inverse: null }),

  short_name: Ember.computed('name', function() {
    var words = this.get('name').split(" ");
    var short_name = words[0] + " " + words[1][0];
    return short_name;
  }),

  genderName: Ember.computed('gender', function() {
    var gender = this.get('gender');
    if (gender === 0) {
      return "None";
    } else if (gender === 1){
      return "Male";
    } else if (gender === 2){
      return "Female";
    } else if (gender === 3){
      return "Other";
    } else {
      return "Unknown";
    }
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
