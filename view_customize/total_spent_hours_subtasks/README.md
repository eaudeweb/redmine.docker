# Total spent time for subtasks

Create one View Customize entry with these values:

| Field | Value |
| --- | --- |
| Path pattern | `/issues/[0-9]+` |
| Project pattern | *(empty)* |
| Insertion position | `Bottom of issue detail` |
| Type | `JavaScript` |
| Enabled | Yes |
| Private | Yes, while testing |

Paste the contents of `code.js` into the Code field.

The customization adds a `Spent time` column immediately after the assignee
and before the deadline field in `#issue_tree`. It loads each visible issue through its
same-origin Redmine issue-detail API endpoint. Branch rows show their direct time and a cumulative total
including all visible descendants, for example `1.00 h (Total: 49.50 h)`. The
cumulative value links to the corresponding spent-time report.

Before enabling it, configure the View Customize plugin:

1. Enable **Automatically create API access key** in the plugin settings.
2. Ensure **Enable REST web service** is enabled under Administration → Settings → API.
