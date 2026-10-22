# Search keyboard shortcuts

Create one View Customize entry with these values:

| Field | Value |
| --- | --- |
| Path pattern | `/.*` |
| Project pattern | *(empty)* |
| Insertion position | `Bottom of all pages` |
| Type | `JavaScript` |
| Comment | Adds Ctrl+E and Ctrl+P keyboard shortcuts |
| Enabled | Yes |
| Private | No, after testing |

Paste the contents of `code.js` into the Code field.

Pressing **Ctrl+E** focuses the global Redmine search field (`#q`) and selects
its current contents. Pressing **Ctrl+P** opens the project drop-down and
focuses its search field (`#projects-quick-search`). The browser's default
shortcut behavior is prevented. Both fields show a tooltip with their keyboard
shortcut when hovered; the Ctrl+P tooltip is also shown on the visible project
drop-down trigger before the list is opened.
