import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('allocation-export-ui', 'Integration | Component | allocation export ui', {
  integration: true
});

test('it renders', function(assert) {
  
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });" + EOL + EOL +

  this.render(hbs`{{allocation-export-ui}}`);

  assert.equal(this.$().text().trim(), '');

  // Template block usage:" + EOL +
  this.render(hbs`
    {{#allocation-export-ui}}
      template block text
    {{/allocation-export-ui}}
  `);

  assert.equal(this.$().text().trim(), 'template block text');
});
