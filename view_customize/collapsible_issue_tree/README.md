# Collapsible issue tree

Create one View Customize entry with these values:

| Field | Value |
| --- | --- |
| Path pattern | `/issues/[0-9]+` |
| Project pattern | *(empty)* |
| Insertion position | `Bottom of issue detail` |
| Type | `JavaScript` |
| Comment | Adds expand/collapse controls for multi-level subtasks |
| Enabled | Yes |
| Private | No, after testing |

Paste the contents of `code.js` into the Code field.

The code is scoped to `#issue_tree` and adds expand/collapse controls for
subtasks with children. It reserves a fixed toggle gutter for every issue row,
so subjects remain aligned whether or not the row has children, and uses a
more visible 24px indentation between hierarchy levels. It does not change
issue data or make additional requests.
