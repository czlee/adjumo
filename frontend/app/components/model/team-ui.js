import Ember from 'ember';
import AdjorTeam from '../../mixins/adjorteam-ui';

export default Ember.Component.extend(AdjorTeam, {

  tagName: 'td',

  classNames: ['team-ui hover-panel-trigger"'],

  adjorTeam: Ember.computed('team', function() {
    return this.get('team'); // Used by adjorteam.js to share properties
  }),
  isTeam: true,

  didInsertElement: function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      //this.$('[data-toggle="tooltip"]').tooltip();

      this.$().popover({
        html : true,
        trigger: 'hover',
        content: function() {
          return $(this).children('.hover-panel').html();
        },
        template: '<div class="popover" role="tooltip"> <div class="arrow"></div> <div class="popover-content"></div> </div>',
        placement: 'top',
        container: 'body',
      });
    });
  }

});
