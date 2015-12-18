import Ember from 'ember';

export default Ember.Component.extend({

  actions: {

    saveConfig: function() {
      this.get('config').save();
      $('#setAllocationParameters').modal('hide');
    }

  }

});
