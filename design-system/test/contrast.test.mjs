import { test } from 'node:test';
import assert from 'node:assert/strict';
import { contrastRatio } from '../contrast.mjs';
import { loadTokens } from '../build.mjs';

const { foundation, themes } = loadTokens();

test('contrastRatio matches known WCAG values', () => {
  assert.equal(contrastRatio('#000000', '#FFFFFF'), 21);
  assert.equal(contrastRatio('#FFFFFF', '#000000'), 21);
  assert.equal(contrastRatio('#777777', '#777777'), 1);
  assert.throws(() => contrastRatio('#FFF', '#000000'), /#RRGGBB/);
});

function checkPalette(label, c, bodyMin) {
  const pairs = [
    ['text', 'bg', bodyMin], ['text', 'surface', bodyMin],
    ['text-muted', 'bg', 4.5], ['text-muted', 'surface', 4.5],
    ['accent', 'bg', 4.5], ['accent', 'surface', 4.5],
    ['on-accent', 'accent', 4.5],
    ['on-highlight', 'highlight', 4.5],
  ];
  for (const [fg, bg, min] of pairs) {
    test(`${label}: ${fg} on ${bg} >= ${min}:1`, () => {
      const r = contrastRatio(c[fg], c[bg]);
      assert.ok(r >= min, `${c[fg]} on ${c[bg]} is ${r.toFixed(2)}:1`);
    });
  }
  test(`${label}: focus ring visible (>= 3:1) on bg and surface`, () => {
    for (const bg of [c.bg, c.surface]) {
      const best = Math.max(contrastRatio(foundation.focus.outer, bg), contrastRatio(foundation.focus.inner, bg));
      assert.ok(best >= 3, `focus on ${bg} is ${best.toFixed(2)}:1`);
    }
  });
}

for (const [name, t] of Object.entries(themes)) {
  checkPalette(name, t.color, name === 'public-service' ? 7 : 4.5);
  if (t.dark) checkPalette(`${name} (dark)`, t.dark.color, 4.5);
}

for (const [k, { bg, fg }] of Object.entries(foundation.status)) {
  test(`status-${k}: text >= 4.5:1`, () => {
    const r = contrastRatio(fg, bg);
    assert.ok(r >= 4.5, `${fg} on ${bg} is ${r.toFixed(2)}:1`);
  });
}
