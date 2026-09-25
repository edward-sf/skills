import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadTokens, renderCss } from '../build.mjs';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const base = readFileSync(join(root, 'base.css'), 'utf8');
const tokensCss = renderCss(loadTokens());
const declared = new Set([...tokensCss.matchAll(/--([a-z0-9-]+):/g)].map((m) => m[1]));

test('base.css only uses variables that tokens.css declares', () => {
  const used = new Set([...base.matchAll(/var\(--([a-z0-9-]+)\)/g)].map((m) => m[1]));
  const missing = [...used].filter((v) => !declared.has(v));
  assert.deepEqual(missing, []);
});

test('base.css contains no literal colours', () => {
  const noComments = base.replace(/\/\*[\s\S]*?\*\//g, '');
  assert.doesNotMatch(noComments, /#[0-9a-f]{3,8}\b|rgba?\(|hsla?\(/i);
});

test('base.css defines every component class in the spec', () => {
  for (const cls of ['site-header', 'ledger', 'card', 'pill', 'pill--success', 'pill--warning', 'pill--danger',
    'pill--info', 'pill--highlight', 'button', 'button--secondary', 'notice', 'notice--success',
    'notice--warning', 'notice--danger', 'notice--info', 'signature', 'mark']) {
    assert.match(base, new RegExp(`\\.${cls}[\\s{:,.]`), `.${cls} missing`);
  }
});
