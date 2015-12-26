import Ember from 'ember';

export default Ember.Component.extend({

  classNameBindings: ['id'],
  classNames: ['debate-ui'],
  tagName: 'tr',

  id: function(){
    return 'debate-' + String(this.get('debate').get('id'));
  }.property('id'),

});
