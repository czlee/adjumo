import Ember from 'ember';

export default Ember.Component.extend({

  store: Ember.inject.service(),

  actions: {

    exportAllocation: function(allocationID) {

      console.log('starting to create a new allocation for #' + event.target.value);

      // Find the selected allocation iteration
      var selectedAllocation;
      this.get('store').findAll('allocation-iteration').forEach(function(allocation) {
        if (allocation.get('id') === allocationID) {
          selectedAllocation = allocation;
          console.log('set allocation');
        }
      });

      var exportData = [];

      selectedAllocation.get('panels').forEach(function(panel) {

        var panellistIDs = [];
        panel.get('panellists').forEach(function(adj) {
          panellistIDs.push(adj.get('id'));
        });

        var traineeIDs = [];
        panel.get('panellists').forEach(function(adj) {
          panellistIDs.push(adj.get('id'));
        });

        exportData.push({
          id: panel.get('debate').get('id'),
          panel: {
            "chair": panel.get('chair').get('id'),
            "panellists": panellistIDs,
            "trainees": traineeIDs,
          },
          strength: 50, // This should be a range from 1-100, have no idea how to generate
          messages: [null],
        });

      });


    }

  }

});
