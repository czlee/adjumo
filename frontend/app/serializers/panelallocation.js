import DS from 'ember-data';
import Ember from 'ember';

export default DS.JSONAPISerializer.extend({

    normalize: function(modelClass, resourceHash) {

      //resourceHash.id = resourceHash.id + Math.floor(Math.random() * 1000000); // TO DO this is dumb but promises were being shit

      return this._super(modelClass, resourceHash);

    },

});
