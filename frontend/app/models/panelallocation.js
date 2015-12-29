import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({

  chair: DS.belongsTo('adjudicator', { inverse: 'panel' }),
  panellists: DS.hasMany('adjudicator', { inverse: 'panel' }),
  trainees: DS.hasMany('adjudicator', { inverse: 'panel' }),

  debate: DS.belongsTo('debate'),

  allocation: DS.belongsTo('allocation-iteration'),
  allocationID: DS.attr('number'),

  score: DS.attr('number'), // deprecate, move to the JSON post

  panelQuality: DS.attr('number'),
  regionalRepresentation: DS.attr('number'),
  genderRepresentation: DS.attr('number'),
  languageRepresentation: DS.attr('number'),

  watchDebateScores: Ember.observer('chair', 'panellists.[]', 'trainees.[]', function() {
    Ember.run.once(this, 'calculateDebateScores'); // Delays checking to the next run loop; prevents doubling up of checks with set/unsetting
  }),

  calculateDebateScores: function() {

    // console.log('calcing scores');
    var thisPanel = this;

    if (this.get('debate').get('teams') !== undefined ) { // Prevent running during initial data load

      var debateData = {
        adjudicators: [],
        teams: [],
      };

      function createAdjJSON(adjudicator) {
        var adjJSON = {
          ranking: adjudicator.get('ranking'),
          region: adjudicator.get('regions')[0],
          language: adjudicator.get('language'),
          gender: adjudicator.get('gender'),
        };
        return adjJSON;
      }
      function createTeamJSON(team) {
        var teamJSON = {
          region: team.get('region'),
          language: team.get('language'),
          gender: team.get('gender'),
        };
        return teamJSON;
      }

      if (thisPanel.get('chair').get('content') !== null ) {
        debateData.adjudicators.push(createAdjJSON(thisPanel.get('chair')));
      }
      if (thisPanel.get('panellists').get('length') > 0 ) {
        this.get('panellists').forEach(function(adj) {
          debateData.adjudicators.push(createAdjJSON(adj));
        });
      }
      // Don't include trainees in this calculation.
      // if (thisPanel.get('trainees').get('length') > 0 ) {
      //   thisPanel.get('trainees').forEach(function(adj) {
      //     debateData.adjudicators.push(createAdjJSON(adj));
      //   });
      // }
      thisPanel.get('debate').get('teams').forEach(function(team) {
        debateData.teams.push(createTeamJSON(team));
      });

      var request = new Ember.RSVP.Promise(function(resolve, reject) {
        Ember.$.ajax({
          url: '/debate-scores',
          data: JSON.stringify(debateData),
          dataType: "json",
          type: "POST",
          contentType: 'application/json;charset=utf-8',
          success: function(response) {
            resolve(response);
          },
          error: function(reason) {
            reject(reason);
          }
        });
      });

      request.then(function(response) {
        //console.log('request success');
        thisPanel.set('panelQuality', response.panelQuality);
        thisPanel.set('regionalRepresentation', response.regionalRepresentation);
        thisPanel.set('genderRepresentation', response.genderRepresentation);
        thisPanel.set('languageRepresentation', response.languageRepresentation);
      }, function(error) {
        console.log('request had error');
        console.log(error);
      });

    }
  },

  ranking: function() {
    var rankings = [];

    if (this.get('chair').get('ranking') !== undefined) {
        rankings.push(this.get('chair').get('ranking'));
    }
    if (this.get('panellists').get('length') > 0) {
        this.get('panellists').forEach(function(adj) {
          rankings.push(adj.get('ranking'));
        });
    }
    if (this.get('trainees').get('length') > 0) {
        this.get('trainees').forEach(function(adj) {
          rankings.push(adj.get('ranking'));
        });
    }

    var sum = 0;
    for( var i = 0; i < rankings.length; i++ ){
      sum += parseInt( rankings[i], 10 ); //don't forget to add the base
    }
    var avg = sum/rankings.length;

    if (avg) {
      return Math.round(avg * 10) / 10;
    } else {
      return 0;
    }

  }.property('chair', 'panellists', 'trainees'),

  regionalRepresentationStr: function() {
    return this.get('regionalRepresentation').toFixed(0);
  }.property('regionalRepresentation'),

  genderRepresentationStr: function() {
    return this.get('genderRepresentation').toFixed(1);
  }.property('genderRepresentation'),

  languageRepresentationStr: function() {
    return this.get('languageRepresentation').toFixed(1);
  }.property('languageRepresentation')

});

