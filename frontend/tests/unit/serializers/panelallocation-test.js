import { moduleForModel, test } from 'ember-qunit';

moduleForModel('panelallocation', 'Unit | Serializer | panelallocation', {
  // Specify the other units that are required for this test.
  needs: ['serializer:panelallocation']
});

// Replace this with your real tests.
test('it serializes records', function(assert) {
  let record = this.subject();

  let serializedRecord = record.serialize();

  assert.ok(serializedRecord);
});
