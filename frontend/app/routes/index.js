import Ember from 'ember';

export default Ember.Route.extend({

  roundInfo: Ember.inject.service('round-info'), // Setup service to pass roundinfo to

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

      var fetchRoundInfo = $.getJSON( '/data/roundinfo.json', {}).done(function( data ) {
        return data.currentround;
      });

      return Ember.RSVP.hash({ // Need this to return multiple model types (these load in parallel as promises)

          config:                 this.defaultConfig,
          regions:                regions,
          round:                  fetchRoundInfo, // single param json
          institutions:           this.store.findAll('institution'),
          adjudicators:           this.store.findAll('adjudicator'),
          teams:                  this.store.findAll('team'),
          debates:                this.store.findAll('debate'),
          allocations:            this.store.findAll('allocation-iteration'), // Permanent file; is blank
          groups:                 this.store.findAll('group'), // Permanent file; has 2 blanks

          instadjconflicts:       this.store.findAll('institutionadjudicator'),
          teamadjconflicts:       this.store.findAll('teamadjudicator'),
          adjadjconflicts:        this.store.findAll('adjudicatorpair'),

          teamadjhistory:         this.store.findAll('teamadjhistory'),
          adjadjhistory:          this.store.findAll('adjadjhistory'),

      });

  },

  setupController(controller, models) {
    // or, more concisely:
    // controller.setProperties(models);

    // This is called after all the previous promises resolve
    controller.set('config', models.config);
    controller.set('regions', models.regions);
    controller.set('institutions', models.institutions);
    controller.set('adjudicators', models.adjudicators);
    controller.set('groups', models.groups);
    controller.set('teams', models.teams);
    controller.set('debates', models.debates);
    controller.set('allocations', models.allocations);

    this.get('roundInfo').set('sequence', models.round.currentround); // Setup the persistant state

  },

  currentAllocationIteration: 0,
  currentAllocation: null,

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
    α: 5,

  },

  actions: {

    createNewAllocation: function() {

      var store = this.store;
      var currentAllocationIteration = this.currentAllocationIteration;
      var currentAllocation = this.currentAllocation;

      currentAllocationIteration += 1;
      //console.log('starting to create a new allocation = ' + currentAllocationIteration);

      // Write all debate importances to a file
      this.store.findAll('debate').then((debates) => {

        // For eachg debate get its importance
        var data = {};
        debates.forEach(function(debate) {
          data[debate.get('id')] = debate.get('importance');
        });

        // Post all the importances
        var posting = $.post( '/debate-importances', data);
        posting.done(function(data) {
          // ASYNC: waiting for file write
          console.log('IMPORTANCES EXPORT: saved importances to file');
        });

        if (currentAllocationIteration !== 1) {

          // Get all the existing panels and clone them if they are from the previous iteration
          this.store.peekAll('panelallocation').forEach(function(panel) {
            // Find and clone the records that were created by the previous allocation
            if (panel.get('allocationID') === currentAllocationIteration - 1) {
              var newID = Number(panel.get('id')) + (1000 * (currentAllocationIteration - 1));
              var newPanel = store.createRecord('panelallocation', {
                id: newID,
                chair: panel.get('chair'),
                panellists: panel.get('panellists'),
                trainees: panel.get('trainees'),
                debate: panel.get('debate'),
                score: panel.get('score'),
                allocationID: 99,
                allocation: panel.get('allocation'),
              });
            }

          });

        }

        // Create the new allocation object
        var newAllocation = this.store.createRecord('allocation-iteration', {
          id: currentAllocationIteration, // Need to increment as allocation ierations start at zero
          active: true,
        });

        //console.log('    loading in data');
        // Load in the allocation information from Julia
        this.store.findAll('panelallocation').then((panels) => {
          panels.forEach(function(panel){
            // console.log('        checking panelID=' + panel.get('id') + ' allocationID=' + panel.get('allocationID'));
            if ((panel.get('allocationID') === undefined) || (panel.get('allocationID') === currentAllocationIteration - 1)) {
              //console.log('            setting panelID=' + panel.get('id') + ' to=' + currentAllocationIteration);
              // For the first run through where the 1-10s are loaded without allocations OR
              // the new elements that were cloned but with the previous rounds iteration
              //console.log('            setting to=' + currentAllocationIteration);
              panel.set('allocationID', currentAllocationIteration);
              panel.set('allocation', newAllocation);
            } else if (panel.get('allocationID') === 99) {
              // For the second run through, these are the cloned elements. They should be set to be the previous iteration
              //console.log('            setting to=' + (currentAllocationIteration - 1));
              panel.set('allocationID', currentAllocationIteration - 1);
            }
          });
        });
        this.currentAllocationIteration = currentAllocationIteration;
        //console.log('finished importing, setting currentAllocation to ' + this.currentAllocationIteration);

      });

      // Export blocks
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
                  debate: { data: { id: debate.get('id'), type: "debate" }},
                  adjudicator: { data: { id: adj.get('id'), type: "adjudicator"}}
                }
              });
            });
          }
        });

        if (blocksData.data.length > 0) { // Only post is groups exist
          var posting = $.post('/blocks', blocksData);
          posting.done(function(blocksData) { // ASYNC: waiting for file write
            console.log('BLOCKS EXPORT: saved blocks data to file');
          });
        } else {
          console.log('BLOCKS EXPORT: no blocks so no blocks data to post');
        }

      });

      // Export locks
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
                  debate: { data: { id: debate.get('id'), type: "debate" }},
                  adjudicator: { data: { id: adj.get('id'), type: "adjudicator"}}
                }
              });
            });
          }
        });

        if (locksData.data.length > 0) { // Only post if locks exist
          var posting = $.post('/locks', locksData);
          posting.done(function() { // ASYNC: waiting for file write
            console.log('LOCK EXPORT: saved locks data to file');
          });
        } else {
          console.log('LOCK EXPORT: no locks so no locks data to post');
        }

      });

      // Export groups
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
            //console.log('____pushed a group');
          }

        });

        if (groupData.data.length > 0) { // Only post is groups exist
          // console.log(groupData);
          var posting = $.post('/groups', groupData);
          posting.done(function(groupData) { // ASYNC: waiting for file write
            console.log('GROUP EXPORT: saved group data to file');
          });
        } else {
          console.log('GROUP EXPORT: no full groups so no group data to post');
        }
      });


    },
  }

});
