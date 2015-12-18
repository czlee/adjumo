import Ember from 'ember';

export default Ember.Route.extend({

  model: function() {

      // console.log('___');
      // var config = this.store.peekRecord('allocation-config', 1);

      // .save().then(function(config) {
      //   console.log(config);
      //   console.log(config.get('quality'));
      // });
      // console.log('___');

      return Ember.RSVP.hash({ // Need this to return multiple model types

          config:                 this.defaultConfig,
          regions:                this.store.findAll('region'),
          institutions:           this.store.findAll('institution'),
          adjudicators:           this.store.findAll('adjudicator'),
          teams:                  this.store.findAll('team'),
          debates:                this.store.findAll('debate'),
          allocations:            this.store.findAll('allocation-iteration', 'id', { reload: true }),

      });
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
  },

  actions: {

    createAllocation: function() {

      this.currentAllocationIteration += 1;

      // Write all debate importances to a file
      var data = {};
      this.store.findAll('debate').then((debate) => {
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
