import Ember from 'ember';

export default Ember.Component.extend({


  actions: {

    exportAllocation: function() {

      var allocation = this.get('allocation');
      console.log('starting to create a new allocation for #' + allocation.get('id'));

      var exportData = [];

      allocation.get('panels').forEach(function(panel) {

        var panellistIDs = []
        panel.get('panellists').forEach(function(adj) {
          panellistIDs.push(adj.get('id'));
        });

        var traineeIDs = []
        panel.get('panellists').forEach(function(adj) {
          traineeIDs.push(adj.get('id'));
        });

        var exportPanel = {
          id: panel.get('debate').get('id'),
          panel: {
            chair: panel.get('chair').get('id'),
            panellists: panellistIDs,
            trainees: traineeIDs,
          },
          strength: 50, // This should be a range from 1-100, have no idea how to generate
          messages: [null],
        };

        exportData.push(exportPanel);

      });


      if (exportData.length > 0) { // Only post is groups exist
        // Replace with a straight up POST to the tabbie2 endpoint
        console.log('exporting: ');
        console.log(JSON.stringify(exportData));

        // var posting = $.post('/tabbie2-test', exportData);
        // posting.done(function() { // ASYNC: waiting for file write
        //   console.log('ALLOCATION EXPORT: saved blocks data to file');
        // });

        $.ajax({
            type: "POST",
            url: "/tabbie2-test",
            //contentType: "application/json; charset=utf-8",
            dataType: "JSON",
            data: { exportData },
            success: function(){
              console.log('ALLOCATION EXPORT: saved blocks data to file');
            }
        });


      } else {
          console.log('ALLOCATION EXPORT: no data');
      }



    }

  }


});
