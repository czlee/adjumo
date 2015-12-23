import Ember from 'ember';

export default Ember.Route.extend({

  model: function() {

      return Ember.RSVP.hash({ // Need this to return multiple model types (these load in parallel as promises)

          config:                 this.defaultConfig,
          regions:                this.store.findAll('region'),
          institutions:           this.store.findAll('institution'),
          adjudicators:           this.store.findAll('adjudicator'),
          teams:                  this.store.findAll('team'),
          debates:                this.store.findAll('debate'),
          allocations:            this.store.findAll('allocation-iteration'),

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
          console.log('saved importances to file');
        });

        var newAllocation = this.store.createRecord('allocation-iteration', {
          id: this.currentAllocationIteration,
        });
        console.log(newAllocation);

        this.store.findAll('panelallocation').then((panels) => {
          panels.forEach(function(item) {
            if (item.get('allocation')) {
              item.set('allocation', newAllocation);
            }
          });
        });

      });

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
      posting.done(function( data ) {
        console.log('saved allocation to file');
      });

    }
  }

});
