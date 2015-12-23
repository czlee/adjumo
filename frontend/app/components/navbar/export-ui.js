import Ember from 'ember';

export default Ember.Component.extend({

  store: Ember.inject.service()

  actions: {

    exportAllocation: function(allocationID) {

      console.log('starting to create a new allocation for #' + event.target.value);

      var debateData = [];
      this.store.findAll('debate').then((debate) => {

        // ASYNC: waiting for find
        debate.forEach(function(debate) {

          debateData.push({
            id: debate.get('id'),
            panel: {
              "chair": <adjid>,
              "panellists": [<adjid>, <adjid>, ...],
              "trainees": [<adjid>, <adjid>, ...]
            },
            strength: 50, // This should be a range from 1-100, have no idea how to generate
            messages: [null],
          }

        });

      }

    }

  }

});
