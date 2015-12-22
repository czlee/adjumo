import Ember from 'ember';
import AdjorTeamDraggableMixin from '../../../mixins/adjor-team-draggable';
import { module, test } from 'qunit';

module('Unit | Mixin | adjor team draggable');

// Replace this with your real tests.
test('it works', function(assert) {
  let AdjorTeamDraggableObject = Ember.Object.extend(AdjorTeamDraggableMixin);
  let subject = AdjorTeamDraggableObject.create();
  assert.ok(subject);
});
