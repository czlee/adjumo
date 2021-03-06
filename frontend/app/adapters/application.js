import DS from 'ember-data';

export default DS.JSONAPIAdapter.extend({

  suffix: '.json',
  host: '',
  namespace: 'data',

  pathForType: function(type) {
    return this._super(type) + this.get('suffix');
  }

});
