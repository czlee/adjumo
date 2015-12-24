import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('allocation-toggle-ui', 'Integration | Component | allocation toggle ui', {
  integration: true
});

test('it renders', function(assert) {
  
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });" + EOL + EOL +

  this.render(hbs`{{allocation-toggle-ui}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:" + EOL +
  this.render(hbs`
    {{#allocation-toggle-ui}}
      template block text
    {{/allocation-toggle-ui}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});
