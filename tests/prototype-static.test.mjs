// Phase 02I-D: source-contract checks only; these do NOT simulate a browser.
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const source=readFileSync(new URL('../prototype/index.html',import.meta.url),'utf8');
const registry=source.match(/const names=\[(.*?)\];/s);
test('canonical registry has 54 titles',()=>{
 assert.ok(registry,'Missing screen registry');
 const titles=JSON.parse('['+registry[1]+']');
 assert.equal(titles.length,54);
 assert.equal(titles[7],'Activity Details');
 assert.equal(titles[15],'Reminder List');
 assert.equal(titles[16],'Reminder Editor');
});
test('demo banner explains temporary behavior',()=>{
 assert.match(source,/DESIGN DEMO/);
 assert.match(source,/Changes are temporary/);
});
test('financial postings are balanced by construction',()=>{
 assert.match(source,/lines\.reduce\(\(s,l\)=>s\+l\.delta,0\)!==0/);
 assert.match(source,/integer|minor|paise/i);
 assert.match(source,/type==="transfer"/);
 assert.match(source,/from===to/);
});
test('editor navigation has dirty guard and confirmation',()=>{
 assert.match(source,/function guardEditor/);
 assert.match(source,/function cancelEditor/);
 assert.match(source,/state\.pendingRoute/);
 assert.match(source,/Discard changes/);
 assert.match(source,/Continue editing/);
});
test('modal includes semantics and background isolation',()=>{
 assert.match(source,/role="dialog"/);
 assert.match(source,/aria-modal="true"/);
 assert.match(source,/app\.inert=on/);
 assert.match(source,/bottom\.inert=on/);
 assert.match(source,/e\.key==="Escape"/);
});
test('responsive and reduced motion contracts are present',()=>{
 assert.match(source,/@media\(min-width:600px\)/);
 assert.match(source,/@media\(prefers-reduced-motion:reduce\)/);
 assert.match(source,/fontSize=state\.large/);
});
test('sample record interactions are wired',()=>{
 for(const key of ['data-detail','data-edit','data-delete','data-toggle','data-savings']){
  assert.ok(source.includes(key),key+' missing');
 }
});
