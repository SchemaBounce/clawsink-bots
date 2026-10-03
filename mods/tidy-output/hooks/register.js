// A mod inside the hosted-session envelope: it reacts to events and talks to
// the UI. It reads no files, runs nothing, reaches no network and approves no
// tool call; the platform guard refuses a mod that tries.
const protectEnv = ($, e, next) =>
  /(^|\/)\.env(\.|$)/.test(String(e.file_path || ''))
    ? { deny: 'tidy-output: .env files are protected' }
    : next(e)

export const register = on => {
  on('session.start', async ($, e, next) => {
    await $.ui.status('tidy-output loaded')
    return next(e)
  })
  // Creating a .env (Write) is guarded as well as changing one (Edit).
  on('tool.call', { tool: 'Edit' }, protectEnv)
  on('tool.call', { tool: 'Write' }, protectEnv)
}
