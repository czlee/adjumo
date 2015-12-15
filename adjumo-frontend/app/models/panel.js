import DS from 'ember-data';

export default DS.Model.extend({

  chair: DS.belongsTo('adjudicator', { inverse: 'panel' }),
  panellists: DS.hasMany('adjudicator', { inverse: 'panel' }),
  trainees: DS.hasMany('adjudicator', { inverse: 'panel' }),

  debate: DS.belongsTo('debate'),

  ranking: function() {
    var rankings = new Array();

    rankings.push(this.get('chair').get('ranking'));

    this.get('panellists').get('content').forEach(function(adj) {
      rankings.push(adj.get('ranking'));
    });

    this.get('trainees').get('content').forEach(function(adj) {
      rankings.push(adj.get('ranking'));
    });

    var sum = 0;
    for( var i = 0; i < rankings.length; i++ ){
      sum += parseInt( rankings[i], 10 ); //don't forget to add the base
    }
    var avg = sum/rankings.length;

    if (avg) {
      return Math.round(avg * 10) / 10;
    } else {
      return 0;
    }

  }.property('chair', 'panellists', 'trainees')

});

