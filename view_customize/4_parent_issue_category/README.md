# Parent issue category

Create one View Customize entry with these values:

| Field | Value |
| --- | --- |
| Path pattern | `/projects/.*/issues/new` |
| Project pattern | *(empty)* |
| Insertion position | `Bottom of issue form` |
| Type | `JavaScript` |
| Comment | Pre-selects the parent issue category on new issues |
| Enabled | Yes |
| Private | No, after testing |

Paste the contents of `code.js` into the Code field.

The customization reads the parent issue from the pre-filled or autocomplete
parent field and selects the same category when the parent has one. It requires
the category field to be empty, so a category selected by the user is never
overridden. It also requires the View Customize setting **Automatically create
API access key** and the Redmine REST web service to be enabled.
