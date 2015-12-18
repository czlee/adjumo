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
    teamhistory: 1,
    adjhistory: 1,
    teamconflict: 1,
    adjconflict: 1,
    quality: 1,
    regional: 1,
    language: 1,
    gender: 9,
  },

  actions: {

    createAllocation: function() {
      this.currentAllocationIteration += 1;

      // Create a new allocation
      var newAllocation = this.store.createRecord('allocation-iteration', {
        id: this.currentAllocationIteration,
      });

      // this.store.findAll('panel').then().filterBy('allocation', null).set('allocation', newAllocation)
      this.store.findAll('panelallocation').then((panels) => {
        panels.forEach(function(item) {
          if (item.get('allocation')) {
            item.set('allocation', newAllocation);
          }
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




      // this.store.findRecord('allocation-config', 1).then((config) =>{
      //   // make a new object each time so it POSTs the whole thing
      //   var test = this.store.createRecord('allocation-config', {
      //       quality: config.get('quality'),
      //       regional: config.get('regional'),
      //       language: config.get('language'),
      //       gender: config.get('gender'),
      //       teamhistory: config.get('teamhistory'),
      //       adjhistory: config.get('adjhistory'),
      //       teamconflict: config.get('teamconflict'),
      //       adjconflict: config.get('adjconflict'),
      //   });
      //   test.save().then(onSuccess, onFail);
      // });


    }


  }



});
