const initializeCollapsibleIssueTree = () => {
  const tree = document.getElementById('issue_tree');
  if (!tree || tree.dataset.collapsibleInitialized) return;

  const rows = Array.from(tree.querySelectorAll('table.issues > tbody > tr.issue'));
  if (!rows.length) return;

    tree.dataset.collapsibleInitialized = 'true';
    const collapsed = new Set();

  const style = document.createElement('style');
  style.textContent = `
    #issue_tree td.subject.issue-tree-subject {
      position: relative;
      background-image: none !important;
    }

    #issue_tree td.subject.issue-tree-subject::before {
      display: none !important;
      content: none !important;
    }

    #issue_tree .issue-tree-gutter {
      display: inline-flex;
      width: 24px;
      height: 17px;
      align-items: center;
      justify-content: center;
      flex: 0 0 24px;
      margin-bottom: 3px;
      line-height: 15px;
      vertical-align: middle;
    }

    #issue_tree .issue-tree-toggle {
      display: inline-flex;
      width: 100%;
      height: 17px;
      align-items: center;
      justify-content: center;
      padding: 0;
      border: 0;
      background: transparent;
      box-shadow: none;
      color: inherit;
      font-size: 1.25em;
      line-height: 15px;
      cursor: pointer;
      appearance: none;
    }

    #issue_tree .issue-tree-toggle:hover,
    #issue_tree .issue-tree-toggle:focus {
      background: rgba(0, 0, 0, 0.08);
    }

    #issue_tree .issue-tree-actions {
      margin-inline-start: 1em;
      font-size: 0.9em;
      font-weight: normal;
    }
  `;
  document.head.appendChild(style);

    const depthOf = (row) => {
      const match = row.className.match(/(?:^|\s)idnt-(\d+)(?:\s|$)/);
      return match ? Number(match[1]) : 0;
    };

    const branchRows = rows.filter((row, index) => {
      const nextRow = rows[index + 1];
      return nextRow && depthOf(nextRow) > depthOf(row);
    });

  const toggleGutterWidth = 24;
  rows.forEach((row) => {
    const subject = row.querySelector('td.subject');
    if (!subject) return;

    const padding = parseFloat(getComputedStyle(subject).paddingInlineStart) || 0;
    const depth = depthOf(row);
    const extraIndentPerLevel = toggleGutterWidth - 16;
    const extraIndent = depth * extraIndentPerLevel;
    subject.classList.add('issue-tree-subject');
    subject.style.paddingInlineStart = `${padding + extraIndent}px`;

    const gutter = document.createElement('span');
    gutter.className = 'issue-tree-gutter';
    subject.prepend(gutter);
  });

  const refresh = () => {
    const collapsedAncestors = [];

    rows.forEach((row) => {
      const depth = depthOf(row);
      while (collapsedAncestors.length && collapsedAncestors.at(-1) >= depth) {
        collapsedAncestors.pop();
      }

      row.hidden = collapsedAncestors.length > 0;
      const toggle = row.querySelector('[data-issue-tree-toggle]');
      if (toggle) {
        const expanded = !collapsed.has(row.id);
        toggle.setAttribute('aria-expanded', String(expanded));
        toggle.setAttribute('title', expanded ? 'Collapse subtasks' : 'Expand subtasks');
        toggle.textContent = expanded ? '−' : '+';
      }

      if (collapsed.has(row.id)) collapsedAncestors.push(depth);
    });
  };

    rows.forEach((row, index) => {
      const nextRow = rows[index + 1];
      if (!nextRow || depthOf(nextRow) <= depthOf(row)) return;

    const subject = row.querySelector('td.subject');
    if (!subject) return;

    const toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.className = 'issue-tree-toggle';
    toggle.dataset.issueTreeToggle = 'true';
    toggle.setAttribute('aria-expanded', 'true');
    toggle.setAttribute('title', 'Collapse subtasks');
    toggle.textContent = '−';
    toggle.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      if (collapsed.has(row.id)) {
        collapsed.delete(row.id);
      } else {
        collapsed.add(row.id);
      }
      refresh();
    });
      subject.querySelector('.issue-tree-gutter').append(toggle);
  });

    const heading = tree.querySelector('p > strong')?.parentElement;
    if (heading) {
      const actions = heading.querySelector('.issue-tree-actions') || document.createElement('span');
      if (!actions.dataset.collapsibleIssueTreeActions) {
        const separator = actions.childNodes.length
          ? '<span aria-hidden="true"> | </span>'
          : '';
        actions.className = 'issue-tree-actions';
        actions.dataset.collapsibleIssueTreeActions = 'true';
        actions.insertAdjacentHTML('afterbegin', `
        <a href="#" data-issue-tree-action="collapse">Collapse all</a>
        <span aria-hidden="true"> | </span>
        <a href="#" data-issue-tree-action="expand">Expand all</a>
        ${separator}
        `);
        actions.addEventListener('click', (event) => {
          const action = event.target.closest('[data-issue-tree-action]');
          if (!action) return;

          event.preventDefault();
          if (action.dataset.issueTreeAction === 'collapse') {
            branchRows.forEach((row) => collapsed.add(row.id));
          } else {
            collapsed.clear();
          }
          refresh();
        });
        if (!actions.parentElement) heading.appendChild(actions);
      }
    }

    refresh();
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeCollapsibleIssueTree, {once: true});
} else {
  initializeCollapsibleIssueTree();
}
