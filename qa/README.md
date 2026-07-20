# QA Toolkit

A Puppeteer-based QA harness for testing Flutter-web apps that use Supabase
auth. Originally built up over several QA sessions on this project; this
folder is meant to be **portable** — copy it into another project and it
works as soon as `config.js` is filled in.

```
qa/
  README.md              this file
  package.json           qa/'s own puppeteer dependency (self-contained)
  config.example.js      template — copy to config.js and fill in
  config.js              your real values (gitignored)
  lib/
    harness.js           reusable, project-agnostic helpers
  scripts/
    examples/            small scripts demonstrating the harness pattern
    *.js                 ~50 one-off scripts accumulated during real QA
                          sessions on THIS project (drane). Not rewritten to
                          use the harness — they predate it and still work
                          standalone (each duplicates the login/wait
                          boilerplate inline). Kept for reference: several
                          encode a working repro for a specific bug. Note:
                          they write screenshots next to themselves
                          (`__dirname`) rather than into `screenshots/`,
                          since that's where they lived before this
                          reorganization — harmless, and still covered by
                          `.gitignore` (`qa/**/*.png`).
  screenshots/            script output (gitignored)
  results/                JSON result dumps from some scripts (gitignored)
```

## Why this exists

Every one-off `node check_x.js` QA script needs the same handful of things:
launch Chrome at the right viewport, wait for Flutter to actually paint
(there's no DOMContentLoaded-equivalent), log in without touching the login
UI, and take a screenshot somewhere predictable. Before this folder existed,
each script on this project copy-pasted that boilerplate inline —
`scripts/*.js` is the archive of that era. `lib/harness.js` is the same
logic, extracted once, so new scripts are ~15 lines instead of ~80.

## Quick start (new project)

```bash
cp -r qa /path/to/other-project/qa
cd /path/to/other-project/qa
npm install                        # installs puppeteer here
cp config.example.js config.js
# edit config.js: chromePath, baseUrl, Supabase project + anon key, test accounts
node scripts/examples/client_home_smoke_test.js
```

If the host project already has `puppeteer` installed at its own root,
`npm install` inside `qa/` is optional — Node's module resolution walks up
parent directories, so `require('puppeteer')` from inside `qa/` will find
it there. Only skip the install if you've confirmed that.

## Quick start (this project, drane)

`config.js` is already filled in. Before running anything:

```bash
flutter build web --release
node ../serve_flutter.js        # serves build/web on :9001 — run from project root
```

Then, e.g.:

```bash
node scripts/examples/client_home_smoke_test.js
```

`serve_flutter.js` stays in the project root (not in `qa/`) because it
hardcodes a relative path to `../build/web` — it's Flutter-project plumbing,
not portable QA logic. Every script here assumes something is already
serving the app at `config.baseUrl`.

## Backend QA via Supabase CLI

For "why does this API call 403 / return empty" style bugs, don't just guess
from Flutter-side symptoms — the `supabase` CLI is already authenticated
against this project's live DB, so it's usually faster to look directly:

```bash
supabase link --project-ref wgujitwmipifuhxavmsn   # first time only, read-only/safe
supabase db query --linked "select * from pg_policies where tablename='objects'" -o json
```

This bypasses RLS like a service-role connection, so read queries (`select`)
are safe to run freely, but treat `insert`/`update`/`create policy` etc. with
the same "confirm before running" care as a `git push` — it mutates
production directly.

## SQL setup / migration scripts

The root-level `supabase_*.sql` files (bucket + RLS setup, migrations) are
gitignored — this repo is public and they expose schema/RLS details that
shouldn't be world-readable. They're bundled as `supabase_sql_scripts.zip`
(also gitignored, local-only) and archived in Notion instead; pull that zip
from Notion and unpack it at the project root if you need them.

## Writing a new script

```js
const config = require('../../config');   // adjust ../.. depth to your script's location
const { launchBrowser, loginAndReload, screenshotPath, watchForErrors } = require('../../lib/harness');

(async () => {
  const { browser, page } = await launchBrowser(config, { width: 1440, height: 2600 });
  watchForErrors(page, 'my_script');       // prints console/page errors as they happen

  await loginAndReload(page, config, config.accounts.client.email, config.accounts.client.password);

  // ... page.mouse.click(...), page.screenshot(...), etc ...

  await page.screenshot({ path: screenshotPath(config, 'my_script_result') });
  await browser.close();
})();
```

See `scripts/examples/client_home_smoke_test.js` for a complete, runnable
example.

## Harness API (`lib/harness.js`)

- `launchBrowser(config, { width, height })` → `{ browser, page }`. Always
  non-headless — Flutter-web canvas rendering is far easier to debug visibly.
- `waitForCanvas(page, timeoutMs=30000)` — polls for `<canvas>` or
  `<flt-glass-pane>`. Use after every `page.goto()`.
- `injectSupabaseLogin(page, config, email, password)` — logs in by hitting
  Supabase's password grant directly and writing the session into
  `localStorage` under `sb-<project-ref>-auth-token`, bypassing the login UI
  entirely. Returns `false` on failure instead of throwing.
- `loginAndReload(page, config, email, password, homePath='/home')` — the
  full reliable sequence: load once unauthenticated so the app boots, inject
  the session, reload so app-level auth listeners re-check on init. A single
  goto+inject without the second reload has been unreliable on this project.
- `screenshotPath(config, name)` — resolves a filename against
  `config.screenshotsDir`.
- `watchForErrors(page, label)` — attaches console/pageerror listeners that
  print only `'error'`-level output. Attach this on every page — skipping it
  has caused real bugs to go unnoticed in past QA runs on this project.

## Conventions worth keeping

- **Viewport per breakpoint, not responsive assumptions.** If the app forks
  into separate desktop/mobile widget trees below some width (common in
  Flutter web), test both explicitly — passing on one tells you nothing
  about the other. This project uses 1440×2600 for desktop, 390×2500 for
  mobile; use tall heights so you rarely need to scroll (`mouse.wheel`
  scrolling on Flutter-web canvases has been unreliable in practice —
  prefer a tall viewport over scrolling when you can).
- **Screenshot coordinates.** When you're shown a screenshot at a scaled-down
  display size, convert back to full resolution before clicking — clicking
  at the coordinates you visually read off a *displayed* (scaled) image will
  miss the target.
- **Don't double-click map widgets rapidly.** flutter_map (and similar
  canvas-rendered maps) can interpret two quick clicks as a pan/drag instead
  of two taps. Screenshot, click once, screenshot again to confirm the
  effect, then proceed.
- **Dialog barriers.** Clicking outside an open dialog's bounds dismisses it
  (hits the modal barrier). If a dialog is already open, don't re-click the
  element that originally opened it — that coordinate is now behind the
  barrier.
- **Don't run parallel QA agents/scripts against the same Chrome
  install without isolation.** Running several Puppeteer scripts
  concurrently (e.g. one agent per user role/breakpoint) can cause window
  focus/viewport to bleed across instances on some machines, producing
  intermittent, hard-to-reproduce "layout bug" reports that are actually
  test-harness cross-talk. If something looks broken only under parallel
  execution, re-run it alone before trusting the report.
- **Don't trust a single QA pass's "bug" report — reproduce it yourself.**
  Across two full QA cycles on this project, every "bug" that looked
  alarming on first report (a session appearing to switch accounts, a map
  never rendering, a card render glitch) turned out to be either intentional
  behavior the checker misread, or an artifact of the check itself — not a
  real defect. A 2-minute standalone repro before escalating a finding saves
  a lot of wasted fix effort.
- **Clean up test data.** Scripts that create real rows (quotes, posts,
  requests) via the app or direct REST calls should delete/revert them
  before finishing, using the same account's access token. If cleanup isn't
  possible (e.g. the row belongs to an account you don't have credentials
  for), say so explicitly rather than leaving it silently.
- **`screenshots/` and `results/` are gitignored.** They're regenerated
  output, not source — don't fight the ignore rules to force-commit them.

## What's *not* in here

`patch_bootstrap.js` (patches `build/web/flutter_bootstrap.js` after a
build) stayed in the project root rather than moving here — it's a build
fix, not a QA check, even though it's adjacent to the same workflow. Seed
scripts that create realistic-looking data for manual QA (`create_chat_room.js`,
`create_test_quote.js`) did move into `scripts/` since they're purely
QA-support. Use your judgment on where that line falls for your own project.
