# New user send-information checkbox

Create one View Customize entry with these values:

| Field | Value |
| --- | --- |
| Path pattern | `/users/new` |
| Project pattern | *(empty)* |
| Insertion position | `Bottom of all pages` |
| Type | `JavaScript` |
| Comment | Moves the send-information checkbox above the Create buttons |
| Enabled | Yes |
| Private | No, after testing |

Paste the contents of `code.js` into the Code field.

The customization moves the **Send account information to the user** field
immediately before the form's Create/Cancel buttons. It only affects the new
user form and does not change the checkbox value.
