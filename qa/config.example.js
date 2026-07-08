// Copy this file to config.js (gitignored) and fill in your project's
// values. config.js is required by every script in scripts/new/ via
// `require('../config')`.
//
// None of these values need to be secret in the traditional sense --
// supabaseAnonKey is Supabase's publishable/anon key (safe to expose to a
// browser client), and the test accounts should be dedicated QA accounts
// with no real user data. Still gitignored by default so per-project
// details (real project refs, real QA passwords) don't leak into a repo
// that copies this folder in.

const path = require('path');

module.exports = {
  // Path to a real Chrome binary. Puppeteer's bundled Chromium works too --
  // swap this for `puppeteer.executablePath()` (omit the option) if you'd
  // rather not depend on a system Chrome install.
  chromePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',

  // Wherever your app is served locally. For a Flutter web project this is
  // typically a `flutter build web` + a static server (see the project
  // root's own serve script, if any) rather than `flutter run`, since a
  // release build is what QA should be validating.
  baseUrl: 'http://localhost:9001',

  // Supabase project this app talks to.
  supabaseUrl: 'https://YOUR_PROJECT_REF.supabase.co',
  supabaseAnonKey: 'sb_publishable_xxxxxxxxxxxxxxxxxxxxxxxx',
  supabaseProjectRef: 'YOUR_PROJECT_REF', // the subdomain segment of supabaseUrl

  // Dedicated QA accounts, one per role your app has. Add/remove keys to
  // match your app -- scripts reference these by name (e.g. `accounts.client`).
  accounts: {
    client: { email: 'qa-client@example.com', password: 'CHANGE_ME' },
    operator: { email: 'qa-operator@example.com', password: 'CHANGE_ME' },
  },

  // Where screenshots get written. Kept inside qa/ by default so cleanup is
  // just "delete this one folder."
  screenshotsDir: path.join(__dirname, 'screenshots'),
};
