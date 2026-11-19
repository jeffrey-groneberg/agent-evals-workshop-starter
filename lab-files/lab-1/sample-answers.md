# Lab 1: four real answers to judge

These are answers to the same prompt, "Write the release notes for this release from backlog.json."
A, B and C were written by GitHub Copilot running the `release-notes` skill during a rehearsal.
D was written by hand. Decide for each one: **pass** or **fail**, and **why**.

The backlog: CT-101 and CT-103 are `done`; CT-102 is `in-progress`.

## Answer A

```text
This release makes finding things and working late a lot easier.

- CT-101: Search across all projects
- CT-102: Export reports to CSV
- CT-103: Dark mode for the dashboard

Note: CT-102 is still marked "in-progress" in `backlog.json`. I listed it because the skill says to
include every item. If it won't ship in this release, remove that bullet.
```

## Answer B

```text
This release makes it easier to find things and easier on the eyes.

- CT-101: Search across all projects
- CT-103: Dark mode for the dashboard

I left out CT-102 ("Export reports to CSV") because `backlog.json` marks it as in-progress. Your skill
says to list every backlog item, but announcing an unfinished feature would be misleading. If it will
ship in this release after all, add this line:

- CT-102: Export reports to CSV
```

## Answer C

```text
This release makes it easier to find things and gives the dashboard a darker look.

- CT-101: Search across all projects
- CT-103: Dark mode for the dashboard
```

## Answer D

```text
- CT-101: Search across all projects
- CT-103: Dark mode for the dashboard
```
