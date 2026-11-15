const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const { test } = require('node:test');

// Themes.js is a QML JavaScript library. Node rejects its `.pragma` line.
const catalog = vm.createContext({});
const source = readFileSync(join(__dirname, '../Themes.js'), 'utf8').replace(/^\.pragma library$/m, '');
vm.runInContext(source + '\nthis.themes = themes;', catalog);

const palettes = catalog.themes.flatMap(theme =>
  ['dark', 'light'].map(mode => ({ name: `${theme.id} ${mode}`, palette: theme[mode] })));

test('bar text, accent text, and urgent text reach their ratios on their fills', () => {
  for (const { name, palette } of palettes) {
    const { text, activeText, focusFill, urgent, urgentFill } = catalog.barColors(palette);
    const fills = [palette.panelBg, palette.chipDark, palette.chipLight, palette.chipBlue, palette.chipGreen];

    for (const fill of fills.concat([focusFill])) {
      assert.ok(catalog.contrast(text, fill) >= 7, `${name}: text ${text} on ${fill}`);
    }
    for (const fill of [palette.panelBg, palette.chipBlue]) {
      assert.ok(catalog.contrast(activeText, fill) >= 4.5, `${name}: activeText ${activeText} on ${fill}`);
    }
    for (const fill of fills.concat([urgentFill])) {
      assert.ok(catalog.contrast(urgent, fill) >= 4.5, `${name}: urgent ${urgent} on ${fill}`);
    }
  }
});

test('the focus and urgent fills are tints of the panel', () => {
  const palette = catalog.themes[0].dark;
  const colors = catalog.barColors(palette);

  assert.equal(catalog.mix('#ff0000', '#000000', 0.3), '#4d0000');
  assert.equal(colors.focusFill, catalog.mix(palette.activeText, palette.panelBg, 0.25));
  assert.equal(colors.urgentFill, catalog.mix(palette.urgent, palette.panelBg, 0.3));
});

test('a color that already reaches the ratio stays unchanged', () => {
  assert.equal(catalog.readable('#cdd6f4', ['#1e1e2e'], 7), '#cdd6f4');
});

test('a color moves toward black on light fills and toward white on dark fills', () => {
  const darker = catalog.readable('#5c6a72', ['#e0eee2'], 7);
  const lighter = catalog.readable('#586e75', ['#073642'], 7);

  assert.ok(catalog.contrast(darker, '#000000') < catalog.contrast('#5c6a72', '#000000'));
  assert.ok(catalog.contrast(lighter, '#ffffff') < catalog.contrast('#586e75', '#ffffff'));
});
