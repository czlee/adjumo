import Ember from 'ember';


  var hardcoded_regions = [
]

export default Ember.Route.extend({

  model: function() {
      return Ember.RSVP.hash({ // Need this to return multiple model types

          regions:        this.store.findAll('region'),

          institutions:   this.store.findAll('institution'),
          // institutions:   function() {
          //                   $.getJSON("data/institutions.json", function (data) {
          //                     console.log('test');
          //                     return $.parseJSON(data);
          //                   });
          //                 },
          adjudicators:   this.store.findAll('adjudicator'),
          // adjudicators:   function() {
          //                   $.getJSON("data/adjudicators.json", function (data) {
          //                     return $.parseJSON(data);
          //                   });
          //                 },
          teams:          this.store.findAll('team'),
          // teams:          function() {
          //                   $.getJSON("data/teams.json", function (data) {
          //                     return $.parseJSON(data);
          //                   });
          //                 },
          debates:        this.store.findAll('debate'), // Makes a GET to /debates (currently handled as mock serve by mirate)
          // debates:        function() {
          //                   $.getJSON("data/debates.json", function (data) {
          //                     return $.parseJSON(data);
          //                   });
          //                 },
          //                   $.getJSON("data/regions.json", function (data) {
          //                     return $.parseJSON(data);
          //                   });
          //                 },
      })
  },

  actions: {


  }



});
