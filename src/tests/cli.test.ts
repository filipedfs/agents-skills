import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { CommanderError } from 'commander';
import { run } from '../cli.js';

describe('CLI root', () => {
  let stdoutSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    stdoutSpy = vi
      .spyOn(process.stdout, 'write')
      .mockImplementation(() => true);
  });

  afterEach(() => {
    stdoutSpy.mockRestore();
  });

  it('prints welcome banner with no arguments', async () => {
    await run(['node', 'aac']);

    const output = stdoutSpy.mock.calls.map((c) => c[0]).join('');
    expect(output).toContain('aac');
    expect(output).toContain('not yet implemented');
  });

  it('prints help with --help', async () => {
    try {
      await run(['node', 'aac', '--help']);
      expect.unreachable('Expected CommanderError to be thrown');
    } catch (error) {
      expect(error).toBeInstanceOf(CommanderError);
      expect((error as CommanderError).exitCode).toBe(0);
    }

    const output = stdoutSpy.mock.calls.map((c) => c[0]).join('');
    expect(output).toContain('sync');
    expect(output).toContain('--help');
  });

  it('prints version with --version', async () => {
    try {
      await run(['node', 'aac', '--version']);
      expect.unreachable('Expected CommanderError to be thrown');
    } catch (error) {
      expect(error).toBeInstanceOf(CommanderError);
      expect((error as CommanderError).exitCode).toBe(0);
    }

    const output = stdoutSpy.mock.calls.map((c) => c[0]).join('');
    expect(output).toContain('0.1.0');
  });

  it('throws CommanderError for unknown command', async () => {
    // Commander writes error output to stderr before throwing
    const stderrSpy = vi
      .spyOn(process.stderr, 'write')
      .mockImplementation(() => true);

    try {
      await run(['node', 'aac', 'unknown-cmd']);
      expect.unreachable('Expected CommanderError to be thrown');
    } catch (error) {
      expect(error).toBeInstanceOf(CommanderError);
      expect((error as CommanderError).exitCode).toBe(1);
    }

    stderrSpy.mockRestore();
  });
});
