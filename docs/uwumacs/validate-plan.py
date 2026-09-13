"""Validate UwUmacs planning links, scope and inventory coverage (no Emacs load)."""
import argparse
import hashlib
import json
import re
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--check-source-snapshot', action='store_true')
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
here = Path(__file__).resolve().parent
inventory = json.loads((here / 'package-inventory.json').read_text(encoding='utf-8'))
records = inventory['integrations']
names = {r['name'] for r in records}
excluded = {r['name'] for r in inventory['inventory_only']}
assert len(names) == len(records), 'duplicate integration names'
assert not names & excluded, 'scheduled and excluded scopes overlap'
assert set(inventory['configured_names']) <= names, 'configured package lacks a ticket'
assert set(inventory['installed_names']) <= names | excluded, 'installed package lacks a disposition'
assert len(inventory['installed_names']) == inventory['installed_count']
assert records and [r['order'] for r in records] == list(range(1, len(records) + 1))
ids = {r['id'] for r in records}
assert len(ids) == len(records)
for r in records:
    assert r['id'] == f"I{r['order']:03}", r['name']
    assert r['action'] and r['acceptance'] and r['test_file'] and r['adapter_file'], r['name']
    assert set(r['dependency_tickets']) <= ids, r['name']
    assert r['id'] not in r['dependency_tickets'], r['name']

spec = root / 'docs/superpowers/specs/2026-09-13-uwumacs-design.md'
plan = root / 'docs/superpowers/plans/2026-09-13-uwumacs.md'
catalogue = here / 'integrations.md'
spec_text = spec.read_text(encoding='utf-8')
plan_text = plan.read_text(encoding='utf-8')
catalogue_text = catalogue.read_text(encoding='utf-8')
for r in records:
    assert len(re.findall(r'\| ' + re.escape(r['id']) + r' \|', catalogue_text)) == 1, r['id']
    assert f"`{r['name']}`" in catalogue_text, r['name']
for r in inventory['inventory_only']:
    assert f"`{r['name']}`" in catalogue_text, r['name']
constraints = spec_text.split('## 2. Fixed decisions and constraints\n', 1)[1].split('\nThese constraints', 1)[0]
for line in constraints.splitlines():
    if line.startswith('- '):
        assert line in plan_text, 'constraint missing from plan: ' + line
for n in range(18):
    assert f'P{n:02}' in plan_text, n

adr_dir = root / 'docs/ADRs'
adr_index = json.loads((adr_dir / 'index.json').read_text(encoding='utf-8'))
adrs = {r['id']: r for r in adr_index['records']}
assert len(adrs) == len(adr_index['records']), 'duplicate ADR IDs'
adr_texts = {}
covered_tickets = []
covered_tasks = set()
for adr_id, adr in adrs.items():
    assert re.fullmatch(r'ADR-\d{4}', adr_id), adr_id
    assert adr['file'].startswith(adr_id[4:] + '-'), adr_id
    assert adr['status'] in {'accepted', 'selected', 'superseded'}, adr_id
    assert adr['origin'] and adr['implementation'] and adr['recorded'], adr_id
    body = (adr_dir / adr['file']).read_text(encoding='utf-8')
    adr_texts[adr_id] = body
    assert body.startswith(f"# {adr_id}: {adr['title']}\n"), adr_id
    for key in ('status', 'origin', 'implementation'):
        assert f"- {key.title()}: **{adr[key]}**" in body, (adr_id, key)
    for heading in ('Context', 'Decision', 'Alternatives considered', 'Consequences',
                    'Provenance and implementation references'):
        assert f'## {heading}\n' in body, (adr_id, heading)
    covered_tickets.extend(adr['integration_ids'])
    covered_tasks.update(adr['tasks'])
assert set(covered_tickets) == ids, 'ADR integration coverage mismatch'
assert len(covered_tickets) == len(ids), 'integration assigned to multiple ADRs'
assert covered_tasks == {f'P{n:02}' for n in range(18)}, 'ADR task coverage mismatch'
for r in records:
    adr_path = (here / r['decision_adr']).resolve()
    matches = [key for key, value in adrs.items()
               if (adr_dir / value['file']).resolve() == adr_path]
    assert len(matches) == 1, 'unknown ADR link: ' + r['id']
    adr_id = matches[0]
    assert adr_id in adrs and r['id'] in adrs[adr_id]['integration_ids'], r['id']
    assert r['action'] in adr_texts[adr_id], 'ADR contract drift: ' + r['id']
sections = adr_index['architecture_sections']
assert set(sections) == set(re.findall(r'^## (\d+)\.', spec_text, re.M))
for section, references in sections.items():
    assert references and set(references) <= adrs.keys(), section
assert [r['text'] for r in adr_index['constraints']] == [
    line[2:] for line in constraints.splitlines() if line.startswith('- ')
], 'ADR constraint coverage mismatch'
assert all(r['adr'] in adrs for r in adr_index['constraints'])

for file in (spec, plan, catalogue, here / 'README.md', root / 'AGENTS.md',
             adr_dir / 'README.md', *(adr_dir / r['file'] for r in adrs.values())):
    text = file.read_text(encoding='utf-8')
    assert not re.search(r'\bTBD\b|fill in details|implement later', text, re.I), file
    for link in re.findall(r'\[[^\]\n]*\]\(([^)\n]+)\)', text):
        if re.match(r'[a-zA-Z]+:', link) or link.startswith('#'):
            continue
        target = link.split('#', 1)[0]
        assert (file.parent / target).resolve().exists(), f'{file}: missing {link}'

if args.check_source_snapshot:
    for path, digest in inventory['source_hashes'].items():
        assert hashlib.sha256((root / path).read_bytes()).hexdigest() == digest, 'source snapshot drift: ' + path
print(f"UWUMACS PLAN PASS: {len(records)} ordered tickets, "
      f"{len(inventory['configured_names'])} configured names, "
      f"{inventory['installed_count']} installed packages accounted for, "
      f"{len(excluded)} inventory-only entries, {len(adrs)} ADRs with full contract coverage")
