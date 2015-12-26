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

  regionalRepresentation: DS.attr('number'),
  genderRepresentation: DS.attr('number'),
  languageRepresentation: DS.attr('number'),

  init() {
    console.log('panel allocation created');
  },

  // test1: Ember.observer('chair', 'panellists.[]', 'trainees.[]', function() {
  //   console.log('test2 observered chairs etc');
  // }),

  calculateConflicts: Ember.observer('chair', 'panellists.[]', 'trainees.[]', function() {

    if (this.get('debate').get('teams') !== undefined) {
      // When first loading these seems not to be set

      var debateTeams = this.get('debate').get('teams');
      var debateAdjs = [];
      if (this.get('chair').get('content') !== null ) {
        debateAdjs.push(this.get('chair'));
      }
      if (this.get('panellists').get('length') > 0 ) {
        this.get('panellists').forEach(function(adj) {
          debateAdjs.push(adj);
        });
      }
      if (this.get('trainees').get('length') > 0 ) {
        this.get('trainees').forEach(function(adj) {
          debateAdjs.push(adj);
        });
      }

      debateAdjs.forEach(function(adjudicator) {

        // ADJ TEAM CONFLICTS
        if (adjudicator.get('teamAdjConflicts') !== undefined) {
          adjudicator.get('teamAdjConflicts').forEach(function(conflict) {

            var hasConflict = false;
            debateTeams.forEach(function(debateTeam) {  // Loop through all the teams and check if they match
              if (debateTeam.get('id') === conflict.get('team').get('id')) {
                hasConflict = true;
                //console.log('      setting active team adj conflict ' + adjudicator.get('name') + ' vs ' + adjConflict.get('team').get('name'));
              }
            });
            conflict.set('panelActive', hasConflict);
          });
        }

        // ADJ ADJ CONFLICTS
        if (adjudicator.get('adjAdjConflicts') !== undefined) {
          adjudicator.get('adjAdjConflicts').forEach(function(conflict) {
            var conflictingAdj;
            if (conflict.get('adj1').get('id') === adjudicator.get('id')) {
              conflictingAdj = conflict.get('adj2');
            } else {
              conflictingAdj = conflict.get('adj1');
            }
            var hasConflict = false;
            debateAdjs.forEach(function(debateAdjudicator) {  // Loop through all the teams and check if they match
              if (debateAdjudicator.get('id') === conflictingAdj.get('id')) {
                hasConflict = true;
                //console.log('      setting active adj adj conflict ' + adjudicator.get('name') + ' vs ' + conflictingAdj.get('name'));
              }
            });
            conflict.set('panelActive', hasConflict);
          });
        }

        // ADJ TEAM HISTORIES
        if (adjudicator.get('teamAdjHistories') !== undefined) {
          adjudicator.get('teamAdjHistories').forEach(function(history) {
            var hasHistory = false;
            debateTeams.forEach(function(debateTeam) {  // Loop through all the teams and check if they match
              if (debateTeam.get('id') === history.get('team').get('id')) {
                hasHistory = true;
                // /console.log('      setting active team adj history ' + adjudicator.get('name') + ' vs ' + history.get('team').get('name'));
              }
            });
            history.set('panelActive', hasHistory);
          });
        }

        // ADJ ADJ HISTORIES
        if (adjudicator.get('adjAdjHistories') !== undefined) {
          adjudicator.get('adjAdjHistories').forEach(function(history) {
            var conflictingAdj;
            if (history.get('adj1').get('id') === adjudicator.get('id')) {
              conflictingAdj = history.get('adj2');
            } else {
              conflictingAdj = history.get('adj1');
            }
            var hasHistory = false;
            debateAdjs.forEach(function(debateAdjudicator) {  // Loop through all the teams and check if they match
              if (debateAdjudicator.get('id') === conflictingAdj.get('id')) {
                hasHistory = true;
                //console.log('      setting active adj adj history ' + adjudicator.get('name') + ' vs ' + conflictingAdj.get('name'));
              }
            });
            history.set('panelActive', hasHistory);
          });
        }

        // DO THIS so each conflict type has a fresh slate
        debateTeams.forEach(function(debateTeam) {
          debateTeam.set('hasInstitutionalConflict', false);
        });
        adjudicator.set('hasInstitutionalConflict', false);

        // ADJ TEAM INSTITUTIONS
        debateTeams.forEach(function(debateTeam) {  // Loop through all the teams and check if they match
          if (debateTeam.get('institution').get('id') === adjudicator.get('institution').get('id')) {
            if (!adjudicator.get('hasInstitutionalConflict')) {
              adjudicator.set('hasInstitutionalConflict', true);
            }
            if (!debateTeam.get('hasInstitutionalConflict')) {
              debateTeam.set('hasInstitutionalConflict', true);
            }
            //console.log('      setting active instituon team conflict ' + adjudicator.get('name') + ' vs ' + debateTeam.get('name'));
          }
        });

        //ADJ ADJ INSTITUTIONS
        debateAdjs.forEach(function(debateAdjudicator) {  // Loop through all the teams and check if they match
          if (debateAdjudicator.get('id') !== adjudicator.get('id')) {
            if (debateAdjudicator.get('institution').get('id') === adjudicator.get('institution').get('id')) {
              if (!debateAdjudicator.get('hasInstitutionalConflict')) {
                debateAdjudicator.set('hasInstitutionalConflict', true);
              }
              if (!adjudicator.get('hasInstitutionalConflict')) {
                adjudicator.set('hasInstitutionalConflict', true);
              }
              //console.log('      setting active instituon adj conflict ' + adjudicator.get('name') + ' vs ' + debateAdjudicator.get('name'));
            }
          }
        });

      });

    }

  }),


  calculateDebateScores: Ember.observer('chair', 'panellists.[]', 'trainees.[]', function() {

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
      if (thisPanel.get('trainees').get('length') > 0 ) {
        thisPanel.get('trainees').forEach(function(adj) {
          debateData.adjudicators.push(createAdjJSON(adj));
        });
      }
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
        thisPanel.set('regionalRepresentation', response.regionalRepresentation);
        thisPanel.set('genderRepresentation', response.genderRepresentation);
        thisPanel.set('languageRepresentation', response.languageRepresentation);
      }, function(error) {
        console.log('request had error');
        console.log(error);
      });

    }
  }),

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

  }.property('chair', 'panellists', 'trainees')

});

