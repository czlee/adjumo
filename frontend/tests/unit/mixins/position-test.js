import Ember from 'ember';
import PositionMixin from '../../../mixins/position';
import { module, test } from 'qunit';

module('Unit | Mixin | position');

// Replace this with your real tests.
test('it works', function(assert) {
  let PositionObject = Ember.Object.extend(PositionMixin);
  let subject = PositionObject.create();
  assert.ok(subject);
});
