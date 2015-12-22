import Ember from 'ember';
import AdjHolderMixing from '../mixins/adjholder';

export default Ember.Component.extend(AdjHolderMixing, {

  classNames: ['unused-adjs-panel', 'hidden'],

  typeClass: '.unused-adjs-panel', // For resizing
  minHeight: 25,
  maxHeight: 400,

});
