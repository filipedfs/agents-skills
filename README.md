# aac — All Agents Configuration

> Synchronise your AI coding agent setup from one place.

**Status:** Shell only — sync commands are not yet implemented.

## Prerequisites

- [Node.js](https://nodejs.org/) LTS (≥ 20.0.0)

## Setup

```bash
npm install
```

## Usage

### Build and run

```bash
npm run build && npm start
```

### Development (no build step)

```bash
npm run dev
```

### Available Commands

| Command          | Description                              |
| ---------------- | ---------------------------------------- |
| `aac`            | Print welcome banner and current status  |
| `aac sync`       | Placeholder — not yet implemented        |
| `aac --help`     | Show help and available commands         |
| `aac --version`  | Show version number                      |

### Run tests

```bash
npm test
```

## Project Structure

- `agents/` — Agent role definition files (markdown with YAML frontmatter)
- `skills/` — Reserved for future skill definitions
- `src/` — CLI application source code
- `.spec/` — Design documents (PRD, SPEC, STATUS)

## Contributing

See `.spec/` for design documents and architecture decisions.
