import Ember from 'ember';
import AdjorteamMixin from '../../../mixins/adjorteam';
import { module, test } from 'qunit';

module('Unit | Mixin | adjorteam');

// Replace this with your real tests.
test('it works', function(assert) {
  let AdjorteamObject = Ember.Object.extend(AdjorteamMixin);
  let subject = AdjorteamObject.create();
  assert.ok(subject);
});
