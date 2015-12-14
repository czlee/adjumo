import DS from 'ember-data';

export default DS.Model.extend({

  chair: DS.belongsTo('adjudicator', { inverse: 'panel' }),
  panellists: DS.hasMany('adjudicator', { inverse: 'panel' }),
  trainees: DS.hasMany('adjudicator', { inverse: 'panel' }),

  debate: DS.belongsTo('debate'),

  rating: function() {
    var ratings = new Array();

    ratings.push(this.get('chair').get('rating'));

    this.get('panellists').get('content').forEach(function(adj) {
      ratings.push(adj.get('rating'));
    });

    this.get('trainees').get('content').forEach(function(adj) {
      ratings.push(adj.get('rating'));
    });

    var sum = 0;
    for( var i = 0; i < ratings.length; i++ ){
      sum += parseInt( ratings[i], 10 ); //don't forget to add the base
    }
    var avg = sum/ratings.length;

    if (avg) {
      return Math.round(avg * 10) / 10;
    } else {
      return 0;
    }

  }.property('chair', 'panellists', 'trainees')

});

