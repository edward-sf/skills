import { test } from 'node:test';
import assert from 'node:assert/strict';
import { loadTokens, renderCss, THEME_NAMES, THEME_KEYS, COLOR_KEYS, DENSITY } from '../build.mjs';

const { foundation, themes } = loadTokens();
const HEX = /^#[0-9A-F]{6}$/;

test('exactly the six spec themes exist', () => {
  assert.deepEqual(Object.keys(themes).sort(), [...THEME_NAMES].sort());
});

for (const [name, t] of Object.entries(themes)) {
  test(`${name}: defines every theme token and nothing else`, () => {
    const allowed = name === 'personal' ? [...THEME_KEYS, 'dark'] : THEME_KEYS;
    assert.deepEqual(Object.keys(t).sort(), [...allowed].sort());
    assert.deepEqual(Object.keys(t.color).sort(), [...COLOR_KEYS].sort());
    for (const k of COLOR_KEYS) assert.match(t.color[k], HEX, `${name} color.${k}`);
    assert.ok(['light', 'dark'].includes(t.mode));
    assert.ok(['sans', 'mono'].includes(t['font-heading']));
    assert.ok(Object.keys(DENSITY).includes(t.density));
    assert.ok(Number.isInteger(t['text-body']) && t['text-body'] >= 16, 'body text >= 16px');
    assert.ok(Number.isInteger(t.radius) && t.radius >= 0);
  });
}

test('personal dark mode defines every colour and nothing else', () => {
  assert.deepEqual(Object.keys(themes.personal.dark), ['color']);
  assert.deepEqual(Object.keys(themes.personal.dark.color).sort(), [...COLOR_KEYS].sort());
});

test('public-service body text is 18px', () => {
  assert.equal(themes['public-service']['text-body'], 18);
});

test('status and focus live only in the foundation', () => {
  assert.deepEqual(Object.keys(foundation.status).sort(), ['danger', 'info', 'success', 'warning']);
  const css = renderCss({ foundation, themes });
  for (const token of ['--status-success', '--on-status-danger', '--focus:', '--focus-inner']) {
    assert.equal(css.split(token).length - 1, 1, `${token} declared exactly once`);
  }
});

test('personal dark mode follows the system unless data-mode is set', () => {
  const css = renderCss({ foundation, themes });
  assert.match(css, /@media \(prefers-color-scheme: dark\) \{\n  \[data-theme="personal"\]:not\(\[data-mode="light"\]\)/);
  assert.match(css, /\[data-theme="personal"\]\[data-mode="dark"\] \{/);
});
