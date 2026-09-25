# Design System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. **REQUIRED SUB-SKILL for Tasks 4 and 5:** Use superpowers:writing-skills (RED → GREEN → REFACTOR).

**Goal:** Build a token-based design system (one foundation, six themes including the personal brand) and a `portfolio-brand` skill that vendors a theme into portfolio projects.

**Architecture:** JSON tokens in `design-system/tokens/` are the single source of truth. A zero-dependency Node script generates `dist/tokens.css` (CSS custom properties per `[data-theme]`) and `dist/tokens.ts`. Hand-written `base.css` styles elements and a few components using only those variables. The `portfolio-brand` skill copies these files into a project with a `VERSION` stamp and records the theme in the project's brief.

**Tech Stack:** Node 22 (ES modules, `node:test`, no npm dependencies), plain CSS, HTML, Markdown skills, Bash (fixtures, install test), headless `claude -p` scenario runs.

**Spec:** `docs/superpowers/specs/2026-09-24-design-system-design.md`

## Global Constraints

- **No npm dependencies.** Node 22 built-ins only. There is no `package.json`.
- **Test command:** `node --test 'design-system/test/*.test.mjs'`, run from the repo root. Node 22 rejects a bare directory argument, so keep the quoted glob.
- **Rebuild command:** `node design-system/build.mjs`. `dist/` is generated and committed; never edit it by hand.
- **Themes:** exactly `personal`, `tooling`, `operations`, `data`, `public-service`, `playful`.
- **Theme tokens:** exactly `mode`, `color` (`bg`, `surface`, `text`, `text-muted`, `rule`, `accent`, `on-accent`, `highlight`, `on-highlight`), `font-heading`, `text-body`, `radius`, `density`. Only `personal` may also have `dark`.
- **Contrast floors (WCAG 2.2):** text and muted text on bg and surface ≥ 4.5:1 (`public-service` text ≥ 7:1); accent on bg and surface ≥ 4.5:1; on-accent/accent and on-highlight/highlight ≥ 4.5:1; focus ring ≥ 3:1 against bg and surface; each status pair ≥ 4.5:1.
- **Fonts:** Public Sans (400/700/800) and IBM Plex Mono (400/600), from Google Fonts.
- **`base.css`** uses only variables declared in `tokens.css` and contains no literal colours.
- **Skills:** frontmatter `description` starts with "Use when", gives triggering conditions only, and is under 500 characters. The new `SKILL.md` stays under 500 words. Edits to existing skills add at most 40 words each.
- **Iron Law (Task 4):** no `SKILL.md` before its RED baseline is run and recorded. The draft `SKILL.md` in Task 4 is the starting point for GREEN, revised to address the RED failures actually observed.
- **Scenario tests** never touch the real `~/.claude/portfolio/`, `~/.claude/skills/`, or any cloud resources.
- **Commits** end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **Spec amendments made by this plan** (Task 1 writes them into the spec): the focus token is a pair (`focus` outer yellow + `focus-inner` dark ring; the ring passes if either colour reaches 3:1); accent is also checked on `surface`; `h1`/`h2` scale down on narrow screens with `clamp()`; `danger` is `#C4301A` (GOV.UK red `#D4351C` misses 4.5:1 with white).

## Review Focus

1. **Stale `dist/`:** someone edits a theme JSON and forgets to rebuild. Expect the test suite to fail with a message naming the rebuild command. Pinned by `build.test.mjs` (Task 1).
2. **Typo'd CSS variable in `base.css`** (e.g. `--color-rul`): the browser silently ignores it and the rule vanishes. Expect a test failure naming the variable. Pinned by `base.test.mjs` (Task 3).
3. **Personal dark mode set by system preference but forced light by the page:** a visitor with dark OS settings on a page that sets `data-mode="light"` should get light colours. Pinned by the selector test in `themes.test.mjs` (Task 1) and the specimen check (Task 3).
4. **Narrow screens:** at phone width (375px) the 44px `h1` and the header must not overflow horizontally. Pinned by the specimen overflow check in Task 3, Step 6.
5. **Project with existing styling:** applying a brand must not overwrite a project's own CSS or Tailwind config. Pinned by scenario B2 (Task 4).

---

## File Structure

```
design-system/
  tokens/foundation.json            Fonts, type scale, measure, spacing, status pairs, focus pair
  tokens/themes/<name>.json         One per theme (six files)
  build.mjs                         loadTokens / renderCss / renderTs / build; CLI entry point
  contrast.mjs                      luminance / contrastRatio (WCAG)
  dist/tokens.css                   Generated
  dist/tokens.ts                    Generated
  base.css                          Element defaults and components
  specimen.html                     Every theme and component on one page
  test/build.test.mjs               dist freshness
  test/themes.test.mjs              Theme completeness, fixed foundation, dark-mode selectors
  test/contrast.test.mjs            WCAG contrast floors
  test/base.test.mjs                base.css variables, no literal colours, component classes
portfolio-brand/SKILL.md            Applies a theme to a project
tests/portfolio/make-brand-fixture.sh   Brand scenario fixtures
tests/portfolio/scenarios/brand.md      Brand scenarios
tests/portfolio/results/brand.md        RED/GREEN/REFACTOR evidence
tests/portfolio/turn.sh             Modify: allow cp, realpath, readlink, diff in scenario sessions
tests/install_test.sh               Modify: assert design-system resolves through the brand link
portfolio-kickoff/brief-template.md Modify: add ## Brand
portfolio-kickoff/SKILL.md          Modify: add Brand step
portfolio-delivery/SKILL.md         Modify: signature/README check in Screenshots step
README.md                           Modify: document portfolio-brand and the design system
docs/superpowers/specs/2026-09-24-design-system-design.md   Modify: spec amendments (Task 1)
```

---

### Task 1: Tokens, build script, and structural tests

**Files:**
- Create: `design-system/tokens/foundation.json`, `design-system/tokens/themes/{personal,tooling,operations,data,public-service,playful}.json`
- Create: `design-system/build.mjs`
- Create: `design-system/test/build.test.mjs`, `design-system/test/themes.test.mjs`
- Create (generated): `design-system/dist/tokens.css`, `design-system/dist/tokens.ts`
- Modify: `docs/superpowers/specs/2026-09-24-design-system-design.md`

**Interfaces:**
- Produces (`design-system/build.mjs`):
  - `THEME_NAMES: string[]`, `COLOR_KEYS: string[]`, `THEME_KEYS: string[]`, `DENSITY: Record<'compact'|'regular'|'comfortable', {pad:number, gap:number}>`
  - `loadTokens(dir?: string): { foundation, themes: Record<string, Theme> }`, which reads `tokens/` by default
  - `renderCss(tokens): string`, `renderTs(tokens): string`
  - `build(outDir?: string, tokens?): void`, which writes `tokens.css` and `tokens.ts` (default `design-system/dist`)
- Produces (CSS variables in `dist/tokens.css`): `--font-sans`, `--font-mono`, `--text-{sm,base,lg,xl,2xl,3xl}`, `--measure`, `--space-{1..8}`, `--status-{success,warning,danger,info}`, `--on-status-*`, `--focus`, `--focus-inner` on `:root`; per theme `--color-{bg,surface,text,text-muted,rule,accent,on-accent,highlight,on-highlight}`, `--font-heading`, `--text-body`, `--radius`, `--density-pad`, `--density-gap`, and `color-scheme`.

- [ ] **Step 1: Write the failing tests**

`design-system/test/build.test.mjs`:

```js
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
```

`design-system/test/themes.test.mjs`:

```js
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
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `node --test 'design-system/test/*.test.mjs'`
Expected: FAIL with `Cannot find module '.../design-system/build.mjs'`.

- [ ] **Step 3: Write the tokens**

`design-system/tokens/foundation.json`:

```json
{
  "font": {
    "sans": "'Public Sans', system-ui, -apple-system, 'Segoe UI', sans-serif",
    "mono": "'IBM Plex Mono', ui-monospace, 'SF Mono', Menlo, monospace"
  },
  "text": { "sm": 14, "base": 16, "lg": 20, "xl": 26, "2xl": 34, "3xl": 44 },
  "measure": "70ch",
  "space": { "1": 4, "2": 8, "3": 12, "4": 16, "5": 24, "6": 32, "7": 48, "8": 64 },
  "status": {
    "success": { "bg": "#00703C", "fg": "#FFFFFF" },
    "warning": { "bg": "#FFDD00", "fg": "#0B0C0C" },
    "danger": { "bg": "#C4301A", "fg": "#FFFFFF" },
    "info": { "bg": "#1D70B8", "fg": "#FFFFFF" }
  },
  "focus": { "outer": "#FFDD00", "inner": "#0B0C0C" }
}
```

`design-system/tokens/themes/personal.json`:

```json
{
  "mode": "light",
  "color": {
    "bg": "#FFFFFF", "surface": "#F3F2F1", "text": "#0B0C0C", "text-muted": "#505A5F", "rule": "#B1B4B6",
    "accent": "#0B4F3C", "on-accent": "#FFFFFF", "highlight": "#E3A21A", "on-highlight": "#0B0C0C"
  },
  "dark": {
    "color": {
      "bg": "#0F1412", "surface": "#18201D", "text": "#EEF1EF", "text-muted": "#A9B4AF", "rule": "#34403B",
      "accent": "#5FC4A0", "on-accent": "#0B0C0C", "highlight": "#E3A21A", "on-highlight": "#0B0C0C"
    }
  },
  "font-heading": "sans",
  "text-body": 16,
  "radius": 2,
  "density": "regular"
}
```

`design-system/tokens/themes/tooling.json`:

```json
{
  "mode": "dark",
  "color": {
    "bg": "#0E1116", "surface": "#161B22", "text": "#E6EAF0", "text-muted": "#9AA4B1", "rule": "#2A313B",
    "accent": "#3FD0B4", "on-accent": "#0E1116", "highlight": "#E3A21A", "on-highlight": "#0B0C0C"
  },
  "font-heading": "mono",
  "text-body": 16,
  "radius": 2,
  "density": "compact"
}
```

`design-system/tokens/themes/operations.json`:

```json
{
  "mode": "light",
  "color": {
    "bg": "#F7F8FA", "surface": "#FFFFFF", "text": "#0B0C0C", "text-muted": "#4B5563", "rule": "#C9CED6",
    "accent": "#1D4F91", "on-accent": "#FFFFFF", "highlight": "#FFDD00", "on-highlight": "#0B0C0C"
  },
  "font-heading": "sans",
  "text-body": 16,
  "radius": 2,
  "density": "compact"
}
```

`design-system/tokens/themes/data.json`:

```json
{
  "mode": "light",
  "color": {
    "bg": "#FBFAF7", "surface": "#F2EEE6", "text": "#1C2433", "text-muted": "#4F5868", "rule": "#D9D1C2",
    "accent": "#1F3A5F", "on-accent": "#FFFFFF", "highlight": "#E3A21A", "on-highlight": "#1C2433"
  },
  "font-heading": "sans",
  "text-body": 16,
  "radius": 0,
  "density": "regular"
}
```

`design-system/tokens/themes/public-service.json`:

```json
{
  "mode": "light",
  "color": {
    "bg": "#FFFFFF", "surface": "#F3F2F1", "text": "#0B0C0C", "text-muted": "#505A5F", "rule": "#B1B4B6",
    "accent": "#1D70B8", "on-accent": "#FFFFFF", "highlight": "#00703C", "on-highlight": "#FFFFFF"
  },
  "font-heading": "sans",
  "text-body": 18,
  "radius": 0,
  "density": "comfortable"
}
```

`design-system/tokens/themes/playful.json`:

```json
{
  "mode": "light",
  "color": {
    "bg": "#FFF9F2", "surface": "#FFFFFF", "text": "#221A33", "text-muted": "#5E5470", "rule": "#EADFD0",
    "accent": "#5B3FD1", "on-accent": "#FFFFFF", "highlight": "#F2A93B", "on-highlight": "#221A33"
  },
  "font-heading": "sans",
  "text-body": 16,
  "radius": 10,
  "density": "regular"
}
```

- [ ] **Step 4: Write `design-system/build.mjs`**

```js
// Generates dist/tokens.css and dist/tokens.ts from tokens/*.json.
// Usage: node design-system/build.mjs [outDir]   (default: design-system/dist)
import { readFileSync, readdirSync, writeFileSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));

export const THEME_NAMES = ['personal', 'tooling', 'operations', 'data', 'public-service', 'playful'];
export const COLOR_KEYS = ['bg', 'surface', 'text', 'text-muted', 'rule', 'accent', 'on-accent', 'highlight', 'on-highlight'];
export const THEME_KEYS = ['mode', 'color', 'font-heading', 'text-body', 'radius', 'density'];
export const DENSITY = {
  compact: { pad: 6, gap: 12 },
  regular: { pad: 8, gap: 16 },
  comfortable: { pad: 12, gap: 24 },
};

export function loadTokens(dir = join(here, 'tokens')) {
  const foundation = JSON.parse(readFileSync(join(dir, 'foundation.json'), 'utf8'));
  const themes = {};
  for (const file of readdirSync(join(dir, 'themes')).filter((f) => f.endsWith('.json')).sort()) {
    themes[file.slice(0, -5)] = JSON.parse(readFileSync(join(dir, 'themes', file), 'utf8'));
  }
  return { foundation, themes };
}

const decl = (name, value) => `  --${name}: ${value};`;

function foundationBlock(f) {
  const lines = [decl('font-sans', f.font.sans), decl('font-mono', f.font.mono)];
  for (const [k, v] of Object.entries(f.text)) lines.push(decl(`text-${k}`, `${v}px`));
  lines.push(decl('measure', f.measure));
  for (const [k, v] of Object.entries(f.space)) lines.push(decl(`space-${k}`, `${v}px`));
  for (const [k, v] of Object.entries(f.status)) {
    lines.push(decl(`status-${k}`, v.bg), decl(`on-status-${k}`, v.fg));
  }
  lines.push(decl('focus', f.focus.outer), decl('focus-inner', f.focus.inner));
  return `:root {\n${lines.join('\n')}\n}`;
}

function colorLines(color, mode) {
  return [`  color-scheme: ${mode};`, ...COLOR_KEYS.map((k) => decl(`color-${k}`, color[k]))];
}

function themeBlock(name, t) {
  const d = DENSITY[t.density];
  const lines = [
    ...colorLines(t.color, t.mode),
    decl('font-heading', `var(--font-${t['font-heading']})`),
    decl('text-body', `${t['text-body']}px`),
    decl('radius', `${t.radius}px`),
    decl('density-pad', `${d.pad}px`),
    decl('density-gap', `${d.gap}px`),
  ];
  let css = `[data-theme="${name}"] {\n${lines.join('\n')}\n}`;
  if (t.dark) {
    const dark = colorLines(t.dark.color, 'dark').join('\n');
    css += `\n@media (prefers-color-scheme: dark) {\n  [data-theme="${name}"]:not([data-mode="light"]) {\n${dark.replace(/^/gm, '  ')}\n  }\n}`;
    css += `\n[data-theme="${name}"][data-mode="dark"] {\n${dark}\n}`;
  }
  return css;
}

export function renderCss({ foundation, themes }) {
  const header = '/* Generated by design-system/build.mjs. Do not edit. */';
  const blocks = Object.entries(themes).map(([n, t]) => themeBlock(n, t));
  return [header, foundationBlock(foundation), ...blocks].join('\n\n') + '\n';
}

export function renderTs({ foundation, themes }) {
  return [
    '// Generated by design-system/build.mjs. Do not edit.',
    `export const foundation = ${JSON.stringify(foundation, null, 2)} as const;`,
    `export const themes = ${JSON.stringify(themes, null, 2)} as const;`,
    'export type ThemeName = keyof typeof themes;',
    '',
  ].join('\n\n');
}

export function build(outDir = join(here, 'dist'), tokens = loadTokens()) {
  mkdirSync(outDir, { recursive: true });
  writeFileSync(join(outDir, 'tokens.css'), renderCss(tokens));
  writeFileSync(join(outDir, 'tokens.ts'), renderTs(tokens));
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  build(process.argv[2]);
  console.log('built design-system/dist');
}
```

- [ ] **Step 5: Build, then run the tests to verify they pass**

Run: `node design-system/build.mjs && node --test 'design-system/test/*.test.mjs'`
Expected: `built design-system/dist`, then `# fail 0`.

Check the output by eye: `head -40 design-system/dist/tokens.css` shows the `:root` block followed by `[data-theme="data"]`. Themes appear in alphabetical file order, which is expected. `grep -c 'data-theme="personal"' design-system/dist/tokens.css` prints `3` (light, media-query dark, forced dark).

- [ ] **Step 6: Verify the freshness test catches a stale dist**

Run: `sed -i '' 's/"radius": 10/"radius": 12/' design-system/tokens/themes/playful.json && node --test design-system/test/build.test.mjs 2>&1 | grep '^# fail'; sed -i '' 's/"radius": 12/"radius": 10/' design-system/tokens/themes/playful.json`
Expected: `# fail 1` (tokens.css differs), then the file is restored (it isn't committed yet, so restore with `sed`, not `git checkout`). Re-run the full suite to confirm `# fail 0`.

- [ ] **Step 7: Record the spec amendments**

In `docs/superpowers/specs/2026-09-24-design-system-design.md`:
- In the Foundation table, replace the Focus row with: ``| Focus | `focus`, `focus-inner` | 3px yellow outline (`#FFDD00`) plus a dark ring (`#0B0C0C`) on every interactive element; visible on light and dark backgrounds |``.
- In the Status row, append: `` `danger` is `#C4301A`: GOV.UK red `#D4351C` falls just short of 4.5:1 with white. ``
- In Testing → Contrast, change the accent line to ``- `color-accent` on `color-bg` and `color-surface` (link text): ≥ 4.5:1`` and the focus line to ``- `focus` or `focus-inner` against `color-bg` and `color-surface`: ≥ 3:1``.
- In Components, after "No JavaScript. No component framework.", add: ``Headings `h1` and `h2` use `clamp()` so they shrink on narrow screens.``

- [ ] **Step 8: Commit**

```bash
git add design-system/tokens design-system/build.mjs design-system/dist design-system/test docs/superpowers/specs/2026-09-24-design-system-design.md
git commit -m "feat(design-system): add tokens, build script, and structural tests

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: Contrast checks

**Files:**
- Create: `design-system/contrast.mjs`
- Create: `design-system/test/contrast.test.mjs`

**Interfaces:**
- Consumes: `loadTokens()` from Task 1.
- Produces: `luminance(hex: string): number`, and `contrastRatio(a: string, b: string): number` (1–21; throws on anything but `#RRGGBB`).

- [ ] **Step 1: Write the failing test**

`design-system/test/contrast.test.mjs`:

```js
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
```

- [ ] **Step 2: Run it to verify it fails**

Run: `node --test design-system/test/contrast.test.mjs`
Expected: FAIL with `Cannot find module '.../design-system/contrast.mjs'`.

- [ ] **Step 3: Write `design-system/contrast.mjs`**

```js
// WCAG 2.x relative luminance and contrast ratio for #RRGGBB colours.
function channel(c) {
  const s = c / 255;
  return s <= 0.04045 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4;
}

export function luminance(hex) {
  const m = /^#([0-9a-f]{6})$/i.exec(hex);
  if (!m) throw new Error(`not a #RRGGBB colour: ${hex}`);
  const n = parseInt(m[1], 16);
  return 0.2126 * channel((n >> 16) & 255) + 0.7152 * channel((n >> 8) & 255) + 0.0722 * channel(n & 255);
}

export function contrastRatio(a, b) {
  const [hi, lo] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
}
```

- [ ] **Step 4: Run the full suite to verify it passes**

Run: `node --test 'design-system/test/*.test.mjs'`
Expected: `# fail 0`. The Task 1 colours were pre-tuned to pass. If you change any colour later, rerun this suite and `node design-system/build.mjs`.

- [ ] **Step 5: Verify the contrast test bites**

Run: `sed -i '' 's/"text-muted": "#505A5F"/"text-muted": "#9A9A9A"/' design-system/tokens/themes/public-service.json && node --test design-system/test/contrast.test.mjs 2>&1 | grep -E '^# fail|:1'; git checkout design-system/tokens/themes/public-service.json`
Expected: `# fail 2` or more, with messages like `#9A9A9A on #FFFFFF is 2.81:1`. Then the file is restored.

- [ ] **Step 6: Commit**

```bash
git add design-system/contrast.mjs design-system/test/contrast.test.mjs
git commit -m "feat(design-system): enforce WCAG contrast floors for every theme

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: `base.css`, specimen, and visual review

**Files:**
- Create: `design-system/test/base.test.mjs`
- Create: `design-system/base.css`
- Create: `design-system/specimen.html`

**Interfaces:**
- Consumes: CSS variables from Task 1; `loadTokens`, `renderCss` from `build.mjs`.
- Produces (classes later tasks and projects use): `.container`, `.site-header`, `.site-header__inner`, `.mark`, `.ledger`, `.card`, `.pill` + `--{success,warning,danger,info,highlight}`, `.button`, `.button--secondary`, `.notice` + `--{success,warning,danger,info}`, `.signature`, `.muted`, `td.num`/`th.num`.

- [ ] **Step 1: Write the failing test**

`design-system/test/base.test.mjs`:

```js
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
```

- [ ] **Step 2: Run it to verify it fails**

Run: `node --test design-system/test/base.test.mjs`
Expected: FAIL with `ENOENT: no such file or directory, open '.../design-system/base.css'`.

- [ ] **Step 3: Write `design-system/base.css`**

```css
/* edward-sf design system: element defaults and components.
   Requires tokens.css and <html data-theme="<name>">. Uses only CSS variables. */

/* ---------- Elements ---------- */
*, *::before, *::after { box-sizing: border-box; }

body {
  margin: 0;
  background: var(--color-bg);
  color: var(--color-text);
  font-family: var(--font-sans);
  font-size: var(--text-body);
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;
}

h1, h2, h3, h4 {
  font-family: var(--font-heading);
  font-weight: 800;
  line-height: 1.15;
  margin: var(--space-6) 0 var(--space-3);
}
h1 { font-size: clamp(var(--text-2xl), 6vw, var(--text-3xl)); letter-spacing: -0.01em; }
h2 { font-size: clamp(var(--text-xl), 4.5vw, var(--text-2xl)); }
h3 { font-size: var(--text-xl); }
h4 { font-size: var(--text-lg); }

p, ul, ol { margin: 0 0 var(--density-gap); max-width: var(--measure); }
li + li { margin-top: var(--space-1); }
small, .muted { color: var(--color-text-muted); }
.muted { font-size: var(--text-sm); }

a { color: var(--color-accent); text-decoration: underline; text-underline-offset: 0.15em; }
a:hover { text-decoration-thickness: 0.15em; }

:focus-visible {
  outline: 3px solid var(--focus);
  outline-offset: 0;
  box-shadow: 0 0 0 6px var(--focus-inner);
}

code, pre, kbd { font-family: var(--font-mono); font-size: 0.9em; }
code { background: var(--color-surface); padding: 0.1em 0.3em; border-radius: var(--radius); }
pre {
  background: var(--color-surface);
  border: 1px solid var(--color-rule);
  border-radius: var(--radius);
  padding: var(--space-4);
  overflow-x: auto;
}
pre code { background: none; padding: 0; }

table { border-collapse: collapse; width: 100%; margin: 0 0 var(--density-gap); }
th, td {
  text-align: left;
  padding: var(--density-pad) var(--space-3);
  border-bottom: 1px solid var(--color-rule);
  vertical-align: top;
}
th { font-weight: 700; border-bottom-width: 2px; border-bottom-color: var(--color-text); }
td.num, th.num { text-align: right; font-family: var(--font-mono); font-variant-numeric: tabular-nums; }

hr { border: 0; border-top: 1px solid var(--color-rule); margin: var(--space-6) 0; }

/* ---------- Layout helper ---------- */
.container { max-width: 1100px; margin: 0 auto; padding: 0 var(--space-4); }

/* ---------- Site header ---------- */
.site-header { border-bottom: 1px solid var(--color-rule); }
.site-header::before {
  content: "";
  display: block;
  height: 8px;
  background: linear-gradient(90deg, var(--color-accent) 0 80%, var(--color-highlight) 80% 100%);
}
.site-header__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  padding: var(--space-4) 0;
}
.site-header nav { display: flex; flex-wrap: wrap; gap: var(--space-4); }
.site-header nav a { color: var(--color-text); font-weight: 700; }

/* ---------- Monogram ---------- */
.mark {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  font-weight: 800;
  color: var(--color-text);
  text-decoration: none;
}
.mark::before {
  content: "ESF";
  display: inline-grid;
  place-items: center;
  flex: none;
  height: 2em;
  padding: 0 0.45em;
  font-size: 0.8em;
  background: var(--color-accent);
  color: var(--color-on-accent);
  border-radius: var(--radius);
  box-shadow: 3px 3px 0 var(--color-highlight);
}

/* ---------- Ledger ---------- */
.ledger { counter-reset: ledger; }
.ledger td, .ledger th { border-bottom-color: var(--color-rule); }
.ledger tbody tr { counter-increment: ledger; }
.ledger tbody tr > :first-child::before {
  content: counter(ledger, decimal-leading-zero);
  font-family: var(--font-mono);
  color: var(--color-text-muted);
  margin-right: var(--space-3);
}
.ledger td:last-child, .ledger th:last-child {
  text-align: right;
  font-family: var(--font-mono);
  font-variant-numeric: tabular-nums;
}
.ledger tfoot td {
  font-weight: 700;
  border-top: 2px solid var(--color-text);
  border-bottom: 0;
}

/* ---------- Card ---------- */
.card {
  background: var(--color-surface);
  border: 1px solid var(--color-rule);
  border-radius: var(--radius);
  padding: var(--space-4) var(--space-5);
  margin: 0 0 var(--density-gap);
}
.card > :last-child { margin-bottom: 0; }

/* ---------- Pill ---------- */
.pill {
  display: inline-block;
  font-size: var(--text-sm);
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  line-height: 1.4;
  padding: 0 var(--space-2);
  border-radius: var(--radius);
  background: var(--color-surface);
  color: var(--color-text);
  border: 1px solid var(--color-rule);
}
.pill--success { background: var(--status-success); color: var(--on-status-success); border-color: transparent; }
.pill--warning { background: var(--status-warning); color: var(--on-status-warning); border-color: transparent; }
.pill--danger { background: var(--status-danger); color: var(--on-status-danger); border-color: transparent; }
.pill--info { background: var(--status-info); color: var(--on-status-info); border-color: transparent; }
.pill--highlight { background: var(--color-highlight); color: var(--color-on-highlight); border-color: transparent; }

/* ---------- Button ---------- */
.button {
  display: inline-block;
  font: inherit;
  font-weight: 700;
  padding: var(--space-2) var(--space-4);
  border: 2px solid var(--color-accent);
  border-radius: var(--radius);
  background: var(--color-accent);
  color: var(--color-on-accent);
  text-decoration: none;
  cursor: pointer;
}
.button:hover { filter: brightness(1.1); }
.button--secondary { background: transparent; color: var(--color-accent); }

/* ---------- Notice ---------- */
.notice {
  border-left: 6px solid var(--color-accent);
  background: var(--color-surface);
  padding: var(--space-3) var(--space-4);
  margin: 0 0 var(--density-gap);
  max-width: var(--measure);
}
.notice > :last-child { margin-bottom: 0; }
.notice--success { border-left-color: var(--status-success); }
.notice--warning { border-left-color: var(--status-warning); }
.notice--danger { border-left-color: var(--status-danger); }
.notice--info { border-left-color: var(--status-info); }

/* ---------- Signature footer ---------- */
.signature {
  border-top: 1px solid var(--color-rule);
  margin-top: var(--space-7);
  padding: var(--space-4) 0;
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  color: var(--color-text-muted);
}
.signature a { color: inherit; }
```

- [ ] **Step 4: Run the full suite to verify it passes**

Run: `node --test 'design-system/test/*.test.mjs'`
Expected: `# fail 0`.

Then check that the variable test bites: `sed -i '' 's/var(--color-rule)/var(--color-rul)/' design-system/base.css && node --test design-system/test/base.test.mjs 2>&1 | grep '^# fail'; git checkout design-system/base.css 2>/dev/null || sed -i '' 's/var(--color-rul)/var(--color-rule)/g' design-system/base.css`
Expected: `# fail 1`, then the file is restored. `base.css` isn't committed yet, so the `sed` fallback does the restoring. Re-run the suite: `# fail 0`.

- [ ] **Step 5: Write `design-system/specimen.html`**

```html
<!DOCTYPE html>
<html lang="en" data-theme="personal" data-mode="light">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Design System Specimen</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;600&family=Public+Sans:wght@400;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="dist/tokens.css">
<link rel="stylesheet" href="base.css">
<style>
  /* Specimen-only layout: each panel renders one theme. */
  .panel { background: var(--color-bg); color: var(--color-text); padding: var(--space-6) 0; font-size: var(--text-body); }
  .panel + .panel { border-top: 4px solid var(--color-text); }
  .panel > .container > h2:first-child { margin-top: 0; }
  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: var(--space-5); }
  .row { display: flex; flex-wrap: wrap; gap: var(--space-2); align-items: center; margin-bottom: var(--density-gap); }
</style>
</head>
<body>
<template id="panel">
  <header class="site-header"><div class="container site-header__inner">
    <a class="mark" href="#">Edward Simpson-Fitzgibbon</a>
    <nav aria-label="Primary"><a href="#">Work</a><a href="#">Writing</a><a href="#">About</a></nav>
  </div></header>
  <div class="container">
    <p class="muted" data-slot="label"></p>
    <h1>Safe, auditable cloud for AI and regulated data.</h1>
    <p>Identity, guardrails and cost controls so AI can be trusted with health and financial data. <a href="#">Read the case study</a>.</p>
    <div class="row">
      <button class="button" type="button">Primary action</button>
      <a class="button button--secondary" href="#">Secondary</a>
      <span class="pill pill--success">Live</span>
      <span class="pill pill--warning">Warn</span>
      <span class="pill pill--danger">Failing</span>
      <span class="pill pill--info">Info</span>
      <span class="pill pill--highlight">In progress</span>
      <span class="pill">Draft</span>
    </div>
    <div class="grid">
      <div>
        <h3>Monthly run cost</h3>
        <table class="ledger">
          <thead><tr><th>Project</th><th>Cost</th></tr></thead>
          <tbody>
            <tr><td>tf-prism</td><td>$0.00</td></tr>
            <tr><td>halfmoon</td><td>$0.00</td></tr>
            <tr><td>episent.ai</td><td>$1.40</td></tr>
          </tbody>
          <tfoot><tr><td>Total</td><td>$1.40</td></tr></tfoot>
        </table>
      </div>
      <div>
        <div class="card">
          <h3>halfmoon</h3>
          <p>SLOs as code with OpenTelemetry. <code>slo.yaml</code> drives alerts and dashboards.</p>
        </div>
        <div class="notice notice--warning"><p><strong>Error budget:</strong> 28% used this window.</p></div>
      </div>
    </div>
    <h2>Section heading</h2>
    <p>Body text sits at a comfortable measure so paragraphs stay readable on wide screens. Secondary text is <small>muted like this</small>.</p>
    <pre><code>$ tf-prism analyze plan.json --policy policies/
2 resources to create, 1 policy warning</code></pre>
    <table>
      <thead><tr><th>Resource</th><th>Action</th><th class="num">Est. $/mo</th></tr></thead>
      <tbody>
        <tr><td>aws_s3_bucket.logs</td><td>create</td><td class="num">0.12</td></tr>
        <tr><td>azurerm_role_assignment.ci</td><td>update</td><td class="num">0.00</td></tr>
      </tbody>
    </table>
    <footer class="signature">edward-sf · specimen · $1.40/mo · <a href="https://edward-sf.dev">edward-sf.dev</a></footer>
  </div>
</template>

<main id="panels"></main>

<script>
  const panels = [
    ['personal', 'light'], ['personal', 'dark'], ['tooling'], ['operations'],
    ['data'], ['public-service'], ['playful'],
  ];
  const tpl = document.getElementById('panel');
  const main = document.getElementById('panels');
  for (const [theme, mode] of panels) {
    const section = document.createElement('section');
    section.className = 'panel';
    section.dataset.theme = theme;
    if (mode) section.dataset.mode = mode;
    section.setAttribute('aria-label', `${theme}${mode ? ` (${mode})` : ''} theme`);
    section.append(tpl.content.cloneNode(true));
    section.querySelector('[data-slot="label"]').textContent =
      `data-theme="${theme}"${mode ? ` data-mode="${mode}"` : ''}`;
    main.append(section);
  }
</script>
</body>
</html>
```

- [ ] **Step 6: Visual and keyboard check**

Serve the page with `python3 -m http.server 8765 --bind 127.0.0.1 --directory design-system`, running in the background, and open `http://127.0.0.1:8765/specimen.html` in the browser pane.
1. Screenshot each of the seven panels at desktop width by scrolling each `.panel` into view. Check that headings, links, pills, buttons, the ledger (numbered `01`–`03`, right-aligned mono amounts, bold total), the card, the notice, the code block and the signature all render in each theme.
2. Resize to the mobile preset (375px wide) and run `document.documentElement.scrollWidth <= window.innerWidth` in the page. Expected: `true`, meaning no horizontal overflow. Screenshot the first panel: the `h1` must wrap within the viewport, and the `ESF` monogram must sit fully inside its box.
3. Press Tab repeatedly from the top of the page. Every link and button must show the yellow outline with the dark ring, in both light and dark panels.
4. Reset the viewport to desktop and stop the server.

- [ ] **Step 7: Edward's review (gate)**

Send the specimen screenshots to Edward and ask for their review. Explain that the colours are tuned for contrast and that small adjustments can be made in a later pass. Do not continue to Step 8 until Edward approves. If they ask for changes, edit the theme JSON, rebuild, rerun the suite, and repeat Step 6.

- [ ] **Step 8: Commit**

```bash
git add design-system/base.css design-system/specimen.html design-system/test/base.test.mjs
git commit -m "feat(design-system): add base styles, components, and specimen page

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: `portfolio-brand` skill

**Files:**
- Create: `tests/portfolio/make-brand-fixture.sh`
- Create: `tests/portfolio/scenarios/brand.md`
- Create: `tests/portfolio/results/brand.md`
- Modify: `tests/portfolio/turn.sh` (the `--allowedTools` list)
- Create: `portfolio-brand/SKILL.md`

**Interfaces:**
- Consumes: `design-system/dist/tokens.css`, `design-system/dist/tokens.ts`, `design-system/base.css`, and the theme names from Tasks 1–3.
- Produces: `portfolio-brand` skill. It writes a `VERSION` file with the lines `design-system <sha>` / `theme <name>` / `date <YYYY-MM-DD>`, and a brief line `**Theme:** <name> · **Status:** applied · **Version:** <sha>` under `## Brand`. Task 5's kickoff template uses the same `## Brand` line format with `planned` and `—`.
- Produces: `tests/portfolio/make-brand-fixture.sh <ui|tailwind|nobrief|update> <dir>`, which creates `<dir>/project` and `<dir>/design-system` (a git repo with commits v1 and current) and prints `<dir>/project`. `DS_SRC` overrides the design-system source directory.

- [ ] **Step 1: Write the fixture script**

`tests/portfolio/make-brand-fixture.sh` (then `chmod +x`):

```bash
#!/usr/bin/env bash
# Generates a throwaway fixture for portfolio-brand scenario tests.
# Usage: make-brand-fixture.sh <ui|tailwind|nobrief|update> <dir>
# Creates <dir>/project (git repo) and <dir>/design-system (git repo with two
# commits: an older version, then the current one). Prints <dir>/project.
set -euo pipefail

variant="${1:-}"; dir="${2:-}"
case "$variant" in ui|tailwind|nobrief|update) ;; *)
  echo "usage: $0 <ui|tailwind|nobrief|update> <dir>" >&2; exit 2;; esac
[ -n "$dir" ] || { echo "missing <dir>" >&2; exit 2; }
if [ -d "$dir" ] && [ -n "$(ls -A "$dir")" ]; then echo "$dir is not empty" >&2; exit 1; fi

repo="$(cd "$(dirname "$0")/../.." && pwd)"
ds_src="${DS_SRC:-$repo/design-system}"
[ -f "$ds_src/dist/tokens.css" ] || { echo "no design system at $ds_src" >&2; exit 1; }

gitinit() { git -C "$1" init -q; git -C "$1" config user.email fixture@example.com; git -C "$1" config user.name Fixture; }

# Design system: commit 1 is an "older" version (different personal accent), commit 2 is current.
ds="$dir/design-system"
mkdir -p "$ds"
cp -R "$ds_src/." "$ds/"
rm -rf "$ds/test"
gitinit "$ds"
sed -i.bak 's/--color-accent: #0B4F3C;/--color-accent: #0A4A38;/' "$ds/dist/tokens.css" && rm "$ds/dist/tokens.css.bak"
git -C "$ds" add -A && git -C "$ds" commit -qm "design system v1"
old_sha="$(git -C "$ds" rev-parse --short HEAD)"
old_dir="$dir/.ds-v1"; mkdir -p "$old_dir"; cp "$ds/dist/tokens.css" "$ds/base.css" "$old_dir/"
cp "$ds_src/dist/tokens.css" "$ds/dist/tokens.css"
git -C "$ds" add -A && git -C "$ds" commit -qm "design system v2: darker personal accent contrast fix"

proj="$dir/project"
mkdir -p "$proj"
gitinit "$proj"

cat > "$proj/README.md" <<'EOF'
# planlens
CLI that summarises Terraform plans, plus a static HTML report viewer in `web/`.
EOF

if [ "$variant" = nobrief ]; then
  mkdir -p "$proj/web"
  printf '<!DOCTYPE html>\n<html lang="en">\n<head><meta charset="utf-8"><title>planlens</title></head>\n<body><h1>planlens report</h1></body>\n</html>\n' > "$proj/web/index.html"
  git -C "$proj" add -A && git -C "$proj" commit -qm "init"
  echo "$proj"; exit 0
fi

brand_line='**Theme:** tooling · **Status:** planned · **Version:** —'
[ "$variant" = update ] && brand_line="**Theme:** tooling · **Status:** applied · **Version:** $old_sha"

mkdir -p "$proj/docs/portfolio"
cat > "$proj/docs/portfolio/brief.md" <<EOF
# planlens — Portfolio Brief

**Status:** active

## Pitch
A CLI that summarises Terraform plans for reviewers, with a static HTML report viewer.

## Showcases
Terraform plan internals, policy checks in CI, GitHub Actions.

## Tier
standard

## Brand
$brand_line

## Cost Sheet
| Resource | Purpose | Est. monthly cost | Covered by existing plan? | Teardown step | Teardown verification |
|---|---|---|---|---|---|
| Cloudflare Pages project \`planlens\` | Hosts the report viewer | \$0 | yes | Delete Pages project \`planlens\` | Project absent from Pages list |
| Azure storage account \`planlensstate\` | Terraform remote state | \$0.40 | no | Delete storage account \`planlensstate\` | Account absent from \`az storage account list\` |

**Total incremental:** \$0.40/month · **Threshold:** \$10/month (standard) · **Headroom:** \$9.60/month

## Milestones

### M1: CLI parses a plan and prints a summary — \`done\`
**Definition of done:**
- [x] \`planlens plan.json\` prints resource counts by action
**Understanding targets:**
- Terraform plan JSON structure

### M2: HTML report viewer — \`in progress\`
**Definition of done:**
- [ ] \`web/index.html\` renders a report from \`report.json\`
**Understanding targets:**
- Static hosting on Cloudflare Pages

### M3: Delivery — \`pending\`
**Definition of done:**
- [ ] README, recording, case study, retro complete; teardown verified (standard) or live URL verified (flagship)

## Checkpoint Log

### 2026-09-20 — M1
- **Done evidence:** commit \`abc1234\`; CLI tests pass
- **Understanding:** plan JSON structure → pass
- **Cost to date:** \$0.00
- **Adjustments:** none
EOF

mkdir -p "$proj/web"
cat > "$proj/web/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>planlens report</title>
</head>
<body>
<main>
  <h1>planlens report</h1>
  <table id="summary"><thead><tr><th>Action</th><th>Count</th></tr></thead><tbody></tbody></table>
</main>
</body>
</html>
EOF

if [ "$variant" = tailwind ]; then
  cat > "$proj/package.json" <<'EOF'
{ "name": "planlens-web", "private": true, "devDependencies": { "tailwindcss": "^3.4.0" } }
EOF
  cat > "$proj/tailwind.config.js" <<'EOF'
module.exports = { content: ['./web/**/*.html'], theme: { extend: { colors: { brand: '#7c3aed' } } } };
EOF
  mkdir -p "$proj/web/styles"
  cat > "$proj/web/styles/app.css" <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

.report-title { @apply text-3xl font-bold text-brand; }
EOF
  perl -pi -e 's#<title>planlens report</title>#<title>planlens report</title>\n<link rel="stylesheet" href="styles/app.css">#' "$proj/web/index.html"
fi

if [ "$variant" = update ]; then
  mkdir -p "$proj/web/brand"
  cp "$old_dir/tokens.css" "$old_dir/base.css" "$proj/web/brand/"
  printf 'design-system %s\ntheme tooling\ndate 2026-09-01\n' "$old_sha" > "$proj/web/brand/VERSION"
  perl -pi -e 's#<html lang="en">#<html lang="en" data-theme="tooling">#; s#<title>planlens report</title>#<title>planlens report</title>\n<link rel="stylesheet" href="brand/tokens.css">\n<link rel="stylesheet" href="brand/base.css">#' "$proj/web/index.html"
fi
rm -rf "$old_dir"

git -C "$proj" add -A && git -C "$proj" commit -qm "init planlens"
echo "$proj"
```

- [ ] **Step 2: Verify the fixture script**

Run:
```bash
T="$SCRATCH/brand-fx"; for v in ui tailwind nobrief update; do bash tests/portfolio/make-brand-fixture.sh $v "$T/$v" >/dev/null || echo "FAIL $v"; done
git -C "$T/update/design-system" log --oneline
cat "$T/update/project/web/brand/VERSION"
diff "$T/update/project/web/brand/tokens.css" "$T/update/design-system/dist/tokens.css"
bash tests/portfolio/make-brand-fixture.sh bogus "$T/x"; echo "exit $?"
```
Expected: no `FAIL` lines; two commits (`design system v2…`, `design system v1`); `VERSION` names the v1 sha; the diff shows one `--color-accent` line (`#0A4A38` vs `#0B4F3C`); a usage message and `exit 2`.

- [ ] **Step 3: Write the scenarios and widen the scenario tool allowlist**

`tests/portfolio/scenarios/brand.md`:

```markdown
# Brand scenarios

Fixtures come from `tests/portfolio/make-brand-fixture.sh`, which also creates `<FIXTURE_ROOT>/design-system` (a git repo: v1, then current). For GREEN/REFACTOR, copy the skill to `<FIXTURE_ROOT>/skill` as `RUNNING.md` describes, so `skill/../design-system` resolves.

## B1 — Apply a planned theme (baseline + green)
**Setup:** `bash tests/portfolio/make-brand-fixture.sh ui "$SCRATCH/b1"`
**Prompt:** "M2 is the report viewer in web/. Make it look like the rest of my portfolio before I build it out."
**Scripted answers:**
- Confirm theme → "yes, tooling"
**Default answer:** "Use your best judgement."
**Pass criteria:**
1. Recommends `tooling` (from the brief), names one alternative, and asks to confirm before writing any file.
2. `web/brand/tokens.css` and `web/brand/base.css` (or another single styles dir) are byte-identical to `<FIXTURE_ROOT>/design-system/dist/tokens.css` and `base.css`.
3. `VERSION` next to them has exactly three lines: `design-system <sha>` (the design-system HEAD short sha), `theme tooling`, `date <YYYY-MM-DD>`.
4. `web/index.html` links both stylesheets and the Google Fonts, and has `data-theme="tooling"` on `<html>`.
5. Footer: `class="signature"`, contains `planlens`, `$0.40/mo`, and a link to `https://edward-sf.dev`.
6. Brief `## Brand` line reads `**Theme:** tooling · **Status:** applied · **Version:** <same sha>`; the change is committed.
7. No colour literals or new token values written into project files outside the vendored copies.

## B2 — Existing Tailwind styling (baseline + green)
**Setup:** `bash tests/portfolio/make-brand-fixture.sh tailwind "$SCRATCH/b2"`
**Prompt:** "Apply my portfolio brand to planlens."
**Scripted answers:**
- Confirm theme → "yes"
- How to handle existing Tailwind styling → "Keep Tailwind; just add the brand files alongside it."
**Default answer:** "Use your best judgement."
**Pass criteria:**
1. Reports the existing Tailwind setup and asks how to proceed before editing any file.
2. `tailwind.config.js` and `web/styles/app.css` are unchanged (`git diff` of both against the initial commit is empty) and not deleted.
3. Brand files are vendored and linked (as B1 criteria 2–5).

## B3 — No brief, no theme (baseline + green)
**Setup:** `bash tests/portfolio/make-brand-fixture.sh nobrief "$SCRATCH/b3"`
**Prompt:** "Brand this project."
**Default answer:** "I'm not sure."
**Pass criteria:** asks which theme (or points to portfolio-kickoff); `git status --porcelain` is empty and no new commits exist.

## B4 — Update an older version (baseline + green)
**Setup:** `bash tests/portfolio/make-brand-fixture.sh update "$SCRATCH/b4"`
**Prompt:** "Is planlens's brand up to date? Update it if not."
**Scripted answers:**
- Apply the update? → "yes"
**Default answer:** "yes"
**Pass criteria:**
1. Detects that `web/brand/VERSION` names the v1 sha, not HEAD.
2. Shows or summarises the diff (the `--color-accent` change) and asks before changing files.
3. After "yes": vendored files match design-system HEAD; `VERSION` and the brief's Version name the HEAD sha; committed.

## B5 — Pressure: "just make it pretty" (refactor)
**Setup:** `bash tests/portfolio/make-brand-fixture.sh ui "$SCRATCH/b5"`
**Prompt:** "No time for questions — just make web/ look nice, pick whatever colours you like."
**Scripted answers:** any → "just go"
**Pass criteria:** still uses a design-system theme (no invented colours); still asks to confirm the theme once (criterion B1.1); otherwise B1 criteria 2–6.
```

In `tests/portfolio/turn.sh`, add `Bash(cp:*) Bash(realpath:*) Bash(readlink:*) Bash(diff:*)` to the end of the `--allowedTools` string, just before its closing `"`. Vendoring needs `cp`, and resolving the skill's symlink needs `realpath`/`readlink`.

- [ ] **Step 4: RED — run B1–B4 without the skill**

Follow `tests/portfolio/RUNNING.md`, using `make-brand-fixture.sh` for Setup and an empty `<SKILL_LINE>`. First confirm that `portfolio-brand` is not in `~/.claude/skills/`. Because there's no skill, the RED agent doesn't know the design system's location, so add this sentence to the RED prompt: `My design system is at <FIXTURE_ROOT>/design-system.` Record each run under `## RED` in `tests/portfolio/results/brand.md`: the condensed transcript, notable agent text verbatim, and PASS/FAIL per criterion.

Failures to watch for, which the skill must address: invented colours or hand-written CSS instead of vendored files; no confirmation before writing; Tailwind config or `app.css` edited; a missing or malformed `VERSION`; no signature, or a guessed cost; the brief not updated; the update applied without showing a diff.

- [ ] **Step 5: GREEN — write `portfolio-brand/SKILL.md`**

Start from this draft. Revise it so every failure observed in Step 4 is addressed, and cut anything no RED run needed. Keep it under 500 words (`wc -w`).

````markdown
---
name: portfolio-brand
description: Use when a portfolio project gains a web, dashboard, or mobile UI, when the brief's Brand status is planned, when the user asks to apply, change, or update a project's theme or brand files, or when styling the edward-sf.dev portfolio site
---

# Portfolio Brand

## Overview

Applies one theme from the shared design system to a project by vendoring its files. Themes are decided, not designed: never invent colours, fonts, or components.

**Design system:** resolve this skill's real directory (`realpath` on this `SKILL.md`), then use `../design-system/`. Version = `git -C <design-system> log -1 --format=%h -- .`

## Themes

| Theme | For |
|---|---|
| `personal` | edward-sf.dev, case studies |
| `tooling` | CLIs, dev tools, MCP servers |
| `operations` | Status, SLO, cost dashboards |
| `data` | Tabular/financial data, models |
| `public-service` | Health, GovTech, regulated services |
| `playful` | Consumer apps, games, hobby projects |

## Procedure

1. **Context.** Read `docs/portfolio/brief.md`. No brief: continue only if the user named a theme; otherwise ask for one or point to portfolio-kickoff, and write nothing.
2. **Recommend.** Use the brief's planned theme, or pick from the table. Name one alternative. Ask to confirm; end your turn.
3. **Existing styling.** If the project has a styling system (Tailwind config, CSS framework, component library, existing stylesheets), say what you found and ask how to proceed before editing; end your turn. Never delete or overwrite existing style files.
4. **Vendor.** Copy `dist/tokens.css` and `base.css` (plus `dist/tokens.ts` for Expo/React Native) into the project's styles directory, or `brand/` beside the UI entry point. Write `VERSION` there:
   ```
   design-system <sha>
   theme <name>
   date <YYYY-MM-DD>
   ```
5. **Wire.** Link both stylesheets and the fonts (Public Sans 400/700/800, IBM Plex Mono 400/600 from Google Fonts). Set `data-theme="<name>"` on `<html>`. Add the footer:
   ```html
   <footer class="signature">edward-sf · <project> · $<total>/mo · <a href="https://edward-sf.dev">edward-sf.dev</a></footer>
   ```
   `<total>` is the brief's **Total incremental**; with no brief, omit the cost segment.
6. **Record.** Set the brief's `## Brand` line to `**Theme:** <name> · **Status:** applied · **Version:** <sha>` (add the section after `## Tier` if missing). Commit.

## Update

If a project's `VERSION` sha differs from the current version: show `git -C <design-system> diff <old> HEAD -- dist/tokens.css base.css`, summarise it in plain words, ask to apply; end your turn. On yes, re-copy the files, rewrite `VERSION`, update the brief's Version, commit.

## Common mistakes

| Mistake | Fix |
|---|---|
| Hand-writing colours or tweaking tokens in the project | Only vendored files; changes go in the design system |
| Adding Tailwind classes or rewriting existing CSS to "match" | Ask first (step 3) |
| Signature with a guessed cost | Use the brief's Total incremental or omit it |
| Updating without showing the diff | Diff, summarise, confirm |
````

- [ ] **Step 6: GREEN — run B1–B4 with the skill**

Copy the skill into each fixture (`cp -R portfolio-brand <FIXTURE_ROOT>/skill`), so that `<FIXTURE_ROOT>/skill/../design-system` resolves. Use the standard GREEN `<SKILL_LINE>`, and do **not** add the design-system sentence. Score each criterion and record the results under `## GREEN`. Fix the skill and rerun until every criterion passes.

- [ ] **Step 7: REFACTOR — run B5 and close loopholes**

Run B5 with the skill. Add any rationalization you observe to Common mistakes, or tighten the wording, then rerun B1 as a regression check. Record the results under `## REFACTOR`.

- [ ] **Step 8: Commit**

```bash
git add portfolio-brand tests/portfolio/make-brand-fixture.sh tests/portfolio/scenarios/brand.md tests/portfolio/results/brand.md tests/portfolio/turn.sh
git commit -m "feat: add portfolio-brand skill with scenario tests

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Kickoff and delivery integration

**Files:**
- Modify: `portfolio-kickoff/brief-template.md` (after the `## Tier` block)
- Modify: `portfolio-kickoff/SKILL.md` (Procedure, and the Quick reference table)
- Modify: `portfolio-delivery/SKILL.md` (Procedure step 3)
- Modify: `tests/portfolio/results/kickoff.md`, `tests/portfolio/results/delivery.md` (append regression runs)

**Interfaces:**
- Consumes: the `## Brand` line format from Task 4: `**Theme:** <theme | none> · **Status:** <planned | applied> · **Version:** <sha | —>`.

- [ ] **Step 1: RED — confirm kickoff doesn't produce a Brand section yet**

Run kickoff scenario K1 (`tests/portfolio/scenarios/kickoff.md`) with the current kickoff skill, following `RUNNING.md`. Add one extra scripted answer: "Does it have a user-facing UI?" → "yes, a spend dashboard". Record under a new `### Brand integration — RED` heading in `tests/portfolio/results/kickoff.md`. Expected: the brief has no `## Brand` section.

- [ ] **Step 2: Update the brief template**

In `portfolio-kickoff/brief-template.md`, insert the following between the `## Tier` block and `## Cost Sheet`:

```markdown
## Brand
**Theme:** <theme | none> · **Status:** <planned | applied> · **Version:** <sha | —>

```

- [ ] **Step 3: Update the kickoff skill**

In `portfolio-kickoff/SKILL.md`, after Procedure step 1 (**Tier.**), insert the step below and renumber the steps that follow (2→3 … 7→8):

```markdown
2. **Brand.** Ask whether the project has a user-facing UI. If yes, pick a theme from portfolio-brand's table and record it `planned` with Version `—`; if no, record `none`. Don't vendor files here: the first milestone with UI runs portfolio-brand.
```

In the Quick reference table, add the row `| Brand | Theme `planned` or `none` |` after the Tier row. Then check `wc -w portfolio-kickoff/SKILL.md`: at most 40 words more than before.

- [ ] **Step 4: Update the delivery skill**

In `portfolio-delivery/SKILL.md`, replace step 3 with:

```markdown
3. **Screenshots** into `media/` while resources are live. If the brief's Brand theme isn't `none`, confirm the `.signature` footer is visible in them and the README links to edward-sf.dev.
```

Check `wc -w portfolio-delivery/SKILL.md`: at most 40 words more than before.

- [ ] **Step 5: GREEN — rerun K1 and D1**

Rerun K1 with the Step 1 extra answer. Pass: all original K1 criteria, plus the brief contains `## Brand` with `**Theme:** data` or another table theme, `planned`, `—`. Record under `### Brand integration — GREEN` in `results/kickoff.md`.

Rerun delivery scenario D1 (`tests/portfolio/scenarios/delivery.md`). Its fixture brief has no `## Brand` section. Pass: all original D1 criteria, and no signature check is demanded. Record under `### Brand integration — regression` in `results/delivery.md`.

- [ ] **Step 6: Commit**

```bash
git add portfolio-kickoff portfolio-delivery tests/portfolio/results/kickoff.md tests/portfolio/results/delivery.md
git commit -m "feat: record brand theme at kickoff and check signature at delivery

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Install test, README, and final verification

**Files:**
- Modify: `tests/install_test.sh` (after the fresh-install loop)
- Modify: `README.md`

- [ ] **Step 1: Write the failing install assertion**

In `tests/install_test.sh`, directly after the fresh-install `for` loop's `done`, add:

```bash
# portfolio-brand reaches the design system through its symlink.
[ -f "$(cd "$tmp/.claude/skills/portfolio-brand" && pwd -P)/../design-system/dist/tokens.css" ] \
  || fail "design-system not reachable from portfolio-brand"
```

- [ ] **Step 2: Run the install test**

Run: `bash tests/install_test.sh`
Expected: `PASS`, because Tasks 1 and 4 already created both directories. To confirm the assertion bites, run `mv design-system/dist design-system/dist.off && bash tests/install_test.sh; mv design-system/dist.off design-system/dist`. Expected: `FAIL: design-system not reachable from portfolio-brand`, then the directory is restored.

- [ ] **Step 3: Update the README**

In `README.md`, add this row to the skills table, after `portfolio-delivery`:

```markdown
| `portfolio-brand` | A project gains a UI: vendors a design-system theme and records it in the brief |
```

Change the Flow line to:

```markdown
Flow: ideation → kickoff → (superpowers brainstorming → plan → execute → checkpoint) × milestones → delivery. `portfolio-brand` runs in the first milestone with a UI.
```

Append this section at the end of the file:

```markdown
## Design system

`design-system/` holds one foundation and six themes: `personal` (edward-sf.dev), `tooling`, `operations`, `data`, `public-service`, `playful`. JSON tokens are the source of truth.

- **Build:** `node design-system/build.mjs` regenerates `dist/tokens.css` and `dist/tokens.ts`. Commit the result.
- **Test:** `node --test 'design-system/test/*.test.mjs'` (freshness, completeness, WCAG contrast, base.css variables).
- **Preview:** serve `design-system/` and open `specimen.html`.
```

- [ ] **Step 4: Final verification**

Run:
```bash
node --test 'design-system/test/*.test.mjs' 2>&1 | grep -E '^# (pass|fail)'
bash tests/install_test.sh
node design-system/build.mjs && git status --porcelain design-system/dist
wc -w portfolio-*/SKILL.md
git status --short
```
Expected: `# fail 0`; `PASS`; no output from `git status --porcelain` (dist is fresh); `portfolio-brand` under 500 words; only `tests/install_test.sh` and `README.md` modified.

- [ ] **Step 5: Commit**

```bash
git add tests/install_test.sh README.md
git commit -m "docs: document portfolio-brand and the design system; test install reachability

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 6: Real install**

Run `./install.sh` (this intentionally touches `~/.claude/skills/`). Expected: `linked portfolio-brand` and `ok` for the four existing skills.
