import AdjHolderMixing from '../mixins/adjholder';

export default Ember.Component.extend(AdjHolderMixing, {

  classNames: ['all-adjs-panel'],

  typeClass: '.all-adjs-panel', // For resizing
  minHeight: 45,
  maxHeight: 400,


});
