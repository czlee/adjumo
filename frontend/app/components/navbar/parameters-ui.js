import Ember from 'ember';

export default Ember.Component.extend({

  actions: {

    saveConfig: function() {

      $('#setAllocationParameters').modal('hide');
      console.log('creating config');

      var data = {
        quality:      this.config.quality,
        regional:     this.config.regional,
        language:     this.config.language,
        gender:       this.config.gender,
        teamhistory:  this.config.teamhistory,
        adjhistory:   this.config.adjhistory,
        teamconflict: this.config.teamconflict,
        adjconflict:  this.config.adjconflict,
        α:            this.config.α,
      };
      var posting = $.post( '/allocation-configs', data);
      posting.done(function() {
        console.log('saved allocation configurations to file');
      });

    }

  }

});
