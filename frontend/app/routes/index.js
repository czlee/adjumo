import Ember from 'ember';

export default Ember.Route.extend({

  model: function() {

      var regions = [
        this.store.createRecord('region', { id: 1, name: "North Asia" }),
        this.store.createRecord('region', { id: 2, name: "South East Asia" }),
        this.store.createRecord('region', { id: 3, name: "Middle East" }),
        this.store.createRecord('region', { id: 4, name: "Sub Sub-Continent" }),
        this.store.createRecord('region', { id: 5, name: "Africa" }),
        this.store.createRecord('region', { id: 6, name: "ANZ" }),
        this.store.createRecord('region', { id: 7, name: "North America" }),
        this.store.createRecord('region', { id: 8, name: "Latin America" }),
        this.store.createRecord('region', { id: 9, name: "Europe" }),
        this.store.createRecord('region', { id: 10, name: "IONA" })
      ];

      return Ember.RSVP.hash({ // Need this to return multiple model types (these load in parallel as promises)

          config:                 this.defaultConfig,
          regions:                regions,
          institutions:           this.store.findAll('institution'),
          adjudicators:           this.store.findAll('adjudicator'),
          teams:                  this.store.findAll('team'),
          debates:                this.store.findAll('debate'),
          allocations:            this.store.findAll('allocation-iteration'),

          groups:                 [this.store.createRecord('group', { id: 1 }), this.store.createRecord('group', { id: 2 })],

          teamadjconflicts:       this.store.findAll('teamadjudicator'),
          adjadjconflicts:        this.store.findAll('adjudicatorpair'),

          teamadjhistory:         this.store.findAll('teamadjhistory'),
          adjadjhistory:          this.store.findAll('adjadjhistory'),

      });

  },

  setupController(controller, models) {
    // This is called after all the previous promises resolve
    controller.set('config', models.config);
    controller.set('regions', models.regions);
    controller.set('institutions', models.institutions);
    controller.set('adjudicators', models.adjudicators);
    controller.set('groups', models.groups);
    controller.set('teams', models.teams);
    controller.set('debates', models.debates);
    controller.set('allocations', models.allocations);
    // or, more concisely:
    // controller.setProperties(models);
  },

  currentAllocationIteration: 0,

  defaultConfig: {
    id: 1,
    teamhistory: 5,
    adjhistory: 5,
    teamconflict: 5,
    adjconflict: 5,
    quality: 5,
    regional: 5,
    language: 5,
    gender: 5,
    fairness: 5,
  },

  actions: {

    createAllocation: function() {

      console.log('starting to create a new allocation');
      this.currentAllocationIteration += 1;

      // Write all debate importances to a file

      this.store.findAll('debate').then((debate) => {
        var data = {};
        // ASYNC: waiting for find
        debate.forEach(function(debate) {
          data[debate.get('id')] = debate.get('importance');
        });

        var posting = $.post( '/debate-importances', data);
        posting.done(function(data) {
          // ASYNC: waiting for file write
          console.log('IMPORTANCES EXPORT: saved importances to file');
        });

        // Load in the allocation information from Julia
        var newAllocation = this.store.createRecord('allocation-iteration', {
          id: this.currentAllocationIteration,
        });

        this.store.findAll('panelallocation').then((panels) => {
          panels.forEach(function(item) {
            if (item.get('allocation')) {
              item.set('allocation', newAllocation);
            }
          });
        });

      });


      this.store.findAll('debate').then((debate) => {
        var blocksData = { data: [] }; // Hold a representation of all groups

        debate.forEach(function(debate) {
          var blockedAdjs = debate.get('bans');

          if (blockedAdjs.get('length') > 0) { // Need at least two adjs for a group

            // For each blocked adjudicator in this debate
            blockedAdjs.forEach(function(adj) {

              blocksData.data.push({
                id: debate.get('id'),
                type: "adjudicatordebate",
                relationships: {
                  debate: {
                    data: {
                      id: debate.get('id'),
                      type: "debate"
                    }
                  },
                  adjudicator: {
                    data: {
                      id: adj.get('id'),
                      type: "adjudicator"
                    }
                  }
                }
              });
            });

          }

        });

        if (blocksData.data.length > 0) { // Only post is groups exist

          var posting = $.post('/blocks', blocksData);
          posting.done(function(blocksData) { // ASYNC: waiting for file write
            console.log('GROUP EXPORT: saved blocks data to file');
          });

        } else {
          console.log('GROUP EXPORT: no blocks so no blocks data to post');
        }

      });




      this.store.findAll('debate').then((debate) => {
        var locksData = { data: [] }; // Hold a representation of all groups

        debate.forEach(function(debate) {
          var lockedAdjs = debate.get('locks');

          if (lockedAdjs.get('length') > 0) { // Need at least two adjs for a group

            // For each blocked adjudicator in this debate
            lockedAdjs.forEach(function(adj) {

              locksData.data.push({
                id: debate.get('id'),
                type: "adjudicatordebate",
                relationships: {
                  debate: {
                    data: {
                      id: debate.get('id'),
                      type: "debate"
                    }
                  },
                  adjudicator: {
                    data: {
                      id: adj.get('id'),
                      type: "adjudicator"
                    }
                  }
                }
              });
            });

          }

        });

        if (locksData.data.length > 0) { // Only post is groups exist

          var posting = $.post('/locks', locksData);
          posting.done(function(locksData) { // ASYNC: waiting for file write
            console.log('GROUP EXPORT: saved locks data to file');
          });

        } else {
          console.log('GROUP EXPORT: no locks so no locks data to post');
        }

      });



      this.store.findAll('group').then((groups) => {
        var groupData = { data: [] }; // Hold a representation of all groups

        groups.forEach(function(group) {
          var groupAdjs = group.get('groupAdjudicators');

          if (groupAdjs.get('length') > 1) { // Need at least two adjs for a group

            // Basic JSON API representation
            var groupJSON = { id: group.get('id'), type: "groupedadjudicators", relationships: { adjudicators: { data: [] } } }

            // Push each relation
            group.get('groupAdjudicators').forEach(function(adj) {
              groupJSON.relationships.adjudicators.data.push({ id: adj.get('id'), type: "adjudicator" });
            });

            // Return to all grops
            groupData.data.push(groupJSON);
          }

        });

        if (groupData.data.length > 0) { // Only post is groups exist

          var posting = $.post('/groups', groupData);
          posting.done(function(groupData) { // ASYNC: waiting for file write
            console.log('GROUP EXPORT: saved group data to file');
          });

        } else {
          console.log('GROUP EXPORT: no full groups so no group data to post');
        }

      });

      // this.store.findAll('bans').then((ban) => {
      //   var data = {};
      // });

      // this.store.findAll('locks').then((lock) => {
      //   var data = {};
      // });

    },

    finishSaveConfig: function() {

      console.log('creating config');

      var data = {
        quality: this.defaultConfig.quality,
        regional: this.defaultConfig.regional,
        language: this.defaultConfig.language,
        gender: this.defaultConfig.gender,
        teamhistory: this.defaultConfig.teamhistory,
        adjhistory: this.defaultConfig.adjhistory,
        teamconflict: this.defaultConfig.teamconflict,
        adjconflict: this.defaultConfig.adjconflict,
      };
      var posting = $.post( '/allocation-configs', data);
      posting.done(function() {
        console.log('saved allocation to file');
      });

    }
  }

});
