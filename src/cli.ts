import { Command } from 'commander';
import { createRequire } from 'node:module';
import { makeSyncCommand } from './commands/index.js';

const require = createRequire(import.meta.url);
const pkg = require('../package.json') as { version: string };

export function createProgram(): Command {
  const program = new Command();

  program
    .name('aac')
    .version(pkg.version)
    .description(
      'All Agents Configuration — keep your AI coding agent setup in sync.',
    )
    .exitOverride();

  program.addCommand(makeSyncCommand());

  return program;
}

export async function run(argv: string[] = process.argv): Promise<void> {
  const program = createProgram();

  if (argv.length === 2) {
    // No subcommand or flags — print the branded welcome banner.
    const banner = [
      `aac — All Agents Configuration v${pkg.version}`,
      'Synchronise your AI coding agent setup from one place.',
      'Status: shell only — sync commands are not yet implemented.',
      'Run `aac --help` for available commands.',
    ].join('\n');
    process.stdout.write(banner + '\n');
    return;
  }

  await program.parseAsync(argv);
}
