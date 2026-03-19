import { Command } from 'commander';

export function makeSyncCommand(): Command {
  const cmd = new Command('sync');

  cmd
    .description(
      'Synchronise agent configuration across all supported environments. (Not yet implemented)',
    )
    .action(() => {
      process.stdout.write(
        '[aac] sync is not yet implemented. Stay tuned.\n',
      );
    });

  return cmd;
}
