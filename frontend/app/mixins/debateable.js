import DS from 'ember-data';
import Ember from 'ember';

export default Ember.Mixin.create({

  name: DS.attr('string'),
  gender: DS.attr('number'),
  language: DS.attr('number'),
  institution: DS.belongsTo('institution'),

  regionID: Ember.computed('institution', function() {
    if (this.get('institution').get('region').get('id')) {
      return this.get('institution').get('region').get('id');
    }
  }),

  // Both adjs and teams have conflicts/histories with each other
  teamAdjHistories: DS.hasMany('teamadjhistory', { async: true }),
  teamAdjConflicts: DS.hasMany('teamadjudicator', {async: true}),

  hasInstitutionalConflict: false, // Placeholder for when these are separate properties

  regionName: Ember.computed('institution', function() {

    function regionMap(regionID) {
      if (regionID === 0) {
        return "No Gender";
      } else if (regionID === 1){
        return "North Asia";
      } else if (regionID === 2){
        return "South East Asia";
      } else if (regionID === 3){
        return "Middle East";
      } else if (regionID === 4){
        return "South East Asia";
      } else if (regionID === 5){
        return "Africa";
      } else if (regionID === 6){
        return "Oceania";
      } else if (regionID === 7){
        return "North America";
      } else if (regionID === 8){
        return "Latin America";
      } else if (regionID === 9){
        return "Europe";
      } else if (regionID === 10){
        return "IONA";
      } else {
        return "?";
      }
    }

    if (this.get('region')) {
      return regionMap(this.get('region'));
    } else if (this.get('regions')){
      var regionsString = "";
      this.get('regions').forEach(function(region) {
        regionsString += regionMap(region) + ", ";
      });
      return regionsString.substr(0, (regionsString.length - 2)); // remove trailing comma & space
    }

  }),

  languageName: Ember.computed('language', function() {
    var language = this.get('language');
    if (language === 0) {
      return "EPL";
    } else if (language === 1){
      return "ESL";
    } else if (language === 2){
      return "EFL";
    } else {
      return "?";
    }
  }),

});
