import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { build } from '../build.mjs';

const dist = join(dirname(fileURLToPath(import.meta.url)), '..', 'dist');

for (const file of ['tokens.css', 'tokens.ts']) {
  test(`dist/${file} is up to date (run: node design-system/build.mjs)`, () => {
    const out = mkdtempSync(join(tmpdir(), 'ds-build-'));
    build(out);
    assert.equal(readFileSync(join(dist, file), 'utf8'), readFileSync(join(out, file), 'utf8'));
  });
}
