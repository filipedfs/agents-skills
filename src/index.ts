#!/usr/bin/env node

import { CommanderError } from 'commander';
import { run } from './cli.js';

try {
  await run();
} catch (error: unknown) {
  if (error instanceof CommanderError) {
    // Commander exits (--help, --version, unknown command) are handled
    // by Commander's own output. Just set the exit code.
    process.exitCode = error.exitCode;
  } else {
    const message = error instanceof Error ? error.message : String(error);
    process.stderr.write(`[aac] Unexpected error: ${message}\n`);
    process.exitCode = 1;
  }
}
