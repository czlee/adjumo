import Ember from 'ember';
import AdjholderMixin from '../../../mixins/adjholder';
import { module, test } from 'qunit';

module('Unit | Mixin | adjholder');

// Replace this with your real tests.
test('it works', function(assert) {
  let AdjholderObject = Ember.Object.extend(AdjholderMixin);
  let subject = AdjholderObject.create();
  assert.ok(subject);
});
