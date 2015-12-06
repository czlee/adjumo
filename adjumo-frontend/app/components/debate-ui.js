import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  didInsertElement: function() {
    // Auto called after the component is instantiated
    this.set.importance = 10;
    console.log(this);
  }
});
