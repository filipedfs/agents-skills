import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { run } from '../cli.js';

describe('sync command', () => {
  let stdoutSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    stdoutSpy = vi
      .spyOn(process.stdout, 'write')
      .mockImplementation(() => true);
  });

  afterEach(() => {
    stdoutSpy.mockRestore();
  });

  it('prints not-yet-implemented message', async () => {
    await run(['node', 'aac', 'sync']);

    const output = stdoutSpy.mock.calls.map((c) => c[0]).join('');
    expect(output).toContain('not yet implemented');
  });

  it('exits cleanly with no error thrown', async () => {
    // sync should complete without throwing — exit code 0
    await expect(run(['node', 'aac', 'sync'])).resolves.toBeUndefined();
  });
});
