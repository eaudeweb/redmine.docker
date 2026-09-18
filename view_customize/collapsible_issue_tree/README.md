# Collapsible issue tree

Create one View Customize entry with these values:

| Field | Value |
| --- | --- |
| Path pattern | `/issues/[0-9]+` |
| Project pattern | *(empty)* |
| Insertion position | `Bottom of issue detail` |
| Type | `JavaScript` |
| Enabled | Yes |
| Private | No, after testing |

Paste the contents of `code.js` into the Code field.

The code is scoped to `#issue_tree` and adds expand/collapse controls for
subtasks with children. It does not change issue data or make additional
requests.
