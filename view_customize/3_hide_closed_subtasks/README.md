# Hide closed subtasks

Create one View Customize entry with these values:

| Field | Value |
| --- | --- |
| Path pattern | `/issues/[0-9]+` |
| Project pattern | *(empty)* |
| Insertion position | `Bottom of issue detail` |
| Type | `JavaScript` |
| Comment | Adds links to hide or show closed subtasks |
| Enabled | Yes |
| Private | No, after testing |

Paste the contents of `code.js` into the Code field.

The customization adds `Hide closed` and `Show closed` links to the same
action line as the collapsible issue-tree controls. Enable it together with
the `collapsible_issue_tree` customization. Closed issue rows are hidden or
shown without changing issue data.
