#!/usr/bin/env node
// AMDS repository validator.
//   node tool/validate.mjs
// Checks: JSON syntax · empty files · broken relative markdown links ·
// duplicate basenames · stray "doc NN" refs · TODO markers.
// Exit code 1 if any ERROR-level problem is found (WARN does not fail).
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs';
import { join, dirname, resolve, relative, extname, basename } from 'node:path';

const ROOT = new URL('..', import.meta.url).pathname.replace(/^\/([A-Za-z]):/, '$1:');
const IGNORE = new Set(['.git', 'node_modules', '.idea', '.vscode']);

function walk(dir, out = []) {
  for (const e of readdirSync(dir)) {
    if (IGNORE.has(e)) continue;
    const p = join(dir, e);
    if (statSync(p).isDirectory()) walk(p, out);
    else out.push(p);
  }
  return out;
}

const files = walk(ROOT);
const errors = [];
const warns = [];
const rel = (p) => relative(ROOT, p).replace(/\\/g, '/');

// 1. JSON syntax
for (const f of files.filter((f) => extname(f) === '.json')) {
  try { JSON.parse(readFileSync(f, 'utf8')); }
  catch (e) { errors.push(`INVALID JSON  ${rel(f)}  — ${e.message}`); }
}

// 2. empty / near-empty files (allow .gitkeep)
for (const f of files) {
  if (basename(f) === '.gitkeep') continue;
  if (['.md', '.json', '.mjs', '.js', '.txt'].includes(extname(f))) {
    const body = readFileSync(f, 'utf8').trim();
    if (body.length === 0) errors.push(`EMPTY FILE    ${rel(f)}`);
    else if (extname(f) === '.md' && body.length < 40) warns.push(`THIN FILE     ${rel(f)} (${body.length} chars)`);
  }
}

// 3. broken relative markdown links + images
const mdFiles = files.filter((f) => extname(f) === '.md');
const linkRe = /\[[^\]]*\]\(([^)]+)\)/g;
for (const f of mdFiles) {
  const src = readFileSync(f, 'utf8');
  let m;
  while ((m = linkRe.exec(src))) {
    let target = m[1].trim();
    if (/^(https?:|mailto:|#|tel:|data:)/.test(target)) continue;
    if (target.startsWith('<') && target.endsWith('>')) target = target.slice(1, -1);
    const [pathPart] = target.split('#');
    if (!pathPart) continue; // pure anchor
    const abs = resolve(dirname(f), pathPart);
    if (!existsSync(abs)) errors.push(`BROKEN LINK   ${rel(f)}  ->  ${target}`);
  }
}

// 4. stray "doc NN" prose references (should have been converted to links)
for (const f of mdFiles) {
  const src = readFileSync(f, 'utf8');
  const hits = src.match(/\bdocs?\s+(0[1-9]|1[0-7])\b/g);
  if (hits) warns.push(`STALE REF     ${rel(f)}  — "${[...new Set(hits)].join('", "')}"`);
}

// 5. duplicate basenames (excluding README.md, 00-framework.md, index.md by design)
const byName = {};
for (const f of mdFiles) {
  const b = basename(f);
  if (['README.md', '00-framework.md', 'index.md'].includes(b)) continue;
  (byName[b] ||= []).push(rel(f));
}
for (const [b, list] of Object.entries(byName)) {
  if (list.length > 1) warns.push(`DUPLICATE     ${b}  — ${list.join(', ')}`);
}

// 6. TODO / FIXME / placeholder-mistake markers
for (const f of mdFiles) {
  const src = readFileSync(f, 'utf8');
  // real markers only — ignore `TODO` in backticks (it's discussed as a concept in guidelines)
  const stripped = src.replace(/`[^`]*`/g, '').replace(/```[\s\S]*?```/g, '');
  if (/\b(TODO|FIXME|XXX)\b/.test(stripped)) warns.push(`TODO MARKER   ${rel(f)}`);
  if (/\[(APP_NAME|COMPANY_NAME|MODULE_NAME|FEATURE_NAME|ROLE_NAME|USER_NAME|DATA_NAME)\]\(/.test(src))
    errors.push(`PLACEHOLDER-AS-LINK  ${rel(f)}  — a [PLACEHOLDER] used as a link`);
}

// report
const line = (s) => console.log(s);
line(`\nAMDS validate — ${mdFiles.length} markdown, ${files.filter((f) => extname(f) === '.json').length} json\n`);
if (errors.length) { line(`ERRORS (${errors.length}):`); errors.forEach((e) => line('  ✗ ' + e)); line(''); }
if (warns.length) { line(`WARNINGS (${warns.length}):`); warns.forEach((w) => line('  ! ' + w)); line(''); }
if (!errors.length && !warns.length) line('✓ clean');
else if (!errors.length) line('✓ no errors (warnings only)');
process.exit(errors.length ? 1 : 0);
