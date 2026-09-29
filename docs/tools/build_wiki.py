"""Build the documentation wiki: one self-contained HTML page from docs/**/*.md.

Usage (from the data/ folder):
    python docs/tools/build_wiki.py

Writes docs/wiki/index.html. Open it in a browser (needs internet for the
markdown, diagram and code-highlight libraries, loaded from jsdelivr/cdnjs).
Re-run after any doc change. The navigation order comes from NAV below; a
page not listed there is still included, at the end of its folder's group.
"""

import json
import os
import re
import subprocess
from datetime import date

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DOCS = os.path.join(ROOT, 'docs')
OUT = os.path.join(DOCS, 'wiki', 'index.html')
TEMPLATE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'wiki_template.html')

JOBS = ['blm', 'blu', 'brd', 'bst', 'cor', 'dnc', 'drg', 'drk', 'geo', 'pld', 'pup',
        'rdm', 'run', 'sam', 'sch', 'smn', 'thf', 'war', 'whm']
JOB_NAMES = {
    'blm': 'Black Mage', 'blu': 'Blue Mage', 'brd': 'Bard', 'bst': 'Beastmaster',
    'cor': 'Corsair', 'dnc': 'Dancer', 'drg': 'Dragoon', 'drk': 'Dark Knight', 'geo': 'Geomancer',
    'pld': 'Paladin', 'pup': 'Puppetmaster', 'rdm': 'Red Mage', 'run': 'Rune Fencer',
    'sam': 'Samurai', 'sch': 'Scholar', 'smn': 'Summoner', 'thf': 'Thief', 'war': 'Warrior', 'whm': 'White Mage',
}

# (section, group, [doc paths relative to docs/]) in display order.
NAV = [
    ('player', 'Start here', ['README.md', 'user/getting-started/installation.md',
                              'user/getting-started/quick-start.md',
                              'user/guides/how-it-works.md']),
    ('player', 'Guides', ['user/guides/commands.md', 'user/guides/keybinds.md',
                          'user/guides/sets.md', 'user/guides/configuration.md',
                          'user/guides/dualbox.md', 'user/guides/stealth.md',
                          'user/guides/faq.md', 'user/guides/glossary.md']),
    ('player', 'Features', ['user/features/ui.md', 'user/features/auto-tier-system.md',
                            'user/features/equipment-validation.md',
                            'user/features/job-change-manager.md', 'user/features/watchdog.md']),
    ('player', 'Jobs', ['user/jobs/README.md']),
    ('dev', 'Overview', ['dev/README.md', 'dev/maintainer-guide.md']),
    ('dev', 'Architecture', ['dev/architecture/job-change-lifecycle.md',
                             'dev/architecture/characters-and-templates.md']),
    ('dev', 'Systems', ['dev/systems/core-lifecycle.md', 'dev/systems/precast-pipeline.md',
                        'dev/systems/midcast-and-buffs.md', 'dev/systems/commands-and-debug.md',
                        'dev/systems/keybinds-and-custom.md', 'dev/systems/factories-and-helpers.md',
                        'dev/systems/messages.md', 'dev/systems/messages-formatters.md',
                        'dev/systems/messages-catalog.md', 'dev/systems/ui-overlay.md',
                        'dev/systems/equipment-and-inventory.md', 'dev/systems/wardrobe-organizer.md',
                        'dev/systems/dualbox.md', 'dev/systems/stealth.md', 'dev/systems/warp.md']),
    ('dev', 'Data', ['dev/data/spell-databases.md', 'dev/data/ability-and-weaponskill-databases.md',
                     'SMN_BLOOD_PACTS_REFERENCE.md']),
    ('dev', 'Jobs (code)', ['dev/jobs/%s.md' % j for j in JOBS]),
]
JOB_PAGE_ORDER = ['README.md', 'states.md', 'sets.md', 'abilities.md', 'tp-bonus.md']
SECTION_LABELS = {'player': 'Player guide', 'dev': 'Developer reference'}


def read(path):
    with open(path, encoding='utf-8') as f:
        return f.read()


def title_of(md, fallback):
    m = re.search(r'^#\s+(.+?)\s*#*\s*$', md, re.M)
    return re.sub(r'`', '', m.group(1)).strip() if m else fallback


def all_docs():
    found = []
    for base, dirs, files in os.walk(DOCS):
        dirs[:] = [d for d in dirs if d not in ('wiki', 'tools')]
        for name in files:
            if name.endswith('.md'):
                found.append(os.path.relpath(os.path.join(base, name), DOCS).replace(os.sep, '/'))
    return sorted(found)


def job_group(job):
    folder = 'user/jobs/%s/' % job
    here = [p for p in all_docs() if p.startswith(folder)]
    order = {n: i for i, n in enumerate(JOB_PAGE_ORDER)}
    here.sort(key=lambda p: (order.get(p[len(folder):], 99), p))
    return here


def page_id(path):
    return re.sub(r'[^A-Za-z0-9._~-]', '-', path[:-3].replace('/', '.'))


def git_head():
    try:
        return subprocess.check_output(['git', 'log', '-1', '--format=%h %cs'], cwd=ROOT,
                                       text=True).strip()
    except Exception:
        return ''


def build():
    pages, seen, nav = [], set(), []

    def add(section, group, path, label=None):
        full = os.path.join(DOCS, path)
        if path in seen or not os.path.exists(full):
            return None
        seen.add(path)
        md = read(full)
        pid = page_id(path)
        pages.append({'id': pid, 'path': path, 'section': section, 'group': group,
                      'title': label or title_of(md, path), 'md': md})
        return pid

    for section, group, paths in NAV:
        ids = [i for i in (add(section, group, p) for p in paths) if i]
        entry = {'section': section, 'group': group, 'pages': ids, 'children': []}
        if group == 'Jobs':
            for job in JOBS:
                sub = [i for i in (add(section, 'Jobs', p) for p in job_group(job)) if i]
                if sub:
                    entry['children'].append({'label': '%s  %s' % (job.upper(), JOB_NAMES[job]),
                                              'job': job, 'pages': sub})
        nav.append(entry)

    leftovers = [p for p in all_docs() if p not in seen]
    if leftovers:
        ids = [i for i in (add('dev' if p.startswith('dev/') else 'player', 'Other', p)
                           for p in leftovers) if i]
        nav.append({'section': 'dev', 'group': 'Other', 'pages': ids, 'children': []})

    data = {'pages': pages, 'nav': nav, 'sections': SECTION_LABELS,
            'built': date.today().isoformat(), 'commit': git_head(),
            'jobs': [{'code': j, 'name': JOB_NAMES[j],
                      'hub': page_id('user/jobs/%s/README.md' % j)} for j in JOBS]}
    payload = json.dumps(data, ensure_ascii=False).replace('</', '<\\/')
    html = read(TEMPLATE).replace('/*__WIKI_DATA__*/null', payload)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        f.write(html)
    size = os.path.getsize(OUT)
    print('%d pages, %.1f KB -> %s' % (len(pages), size / 1024, os.path.relpath(OUT, ROOT)))
    if leftovers:
        print('not in NAV (added under Other): ' + ', '.join(leftovers))


if __name__ == '__main__':
    build()
