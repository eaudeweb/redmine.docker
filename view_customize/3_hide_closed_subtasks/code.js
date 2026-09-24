const initializeHideClosedSubtasks = () => {
  const tree = document.getElementById('issue_tree');
  if (!tree || tree.dataset.hideClosedSubtasksInitialized) return;

  const rows = Array.from(tree.querySelectorAll('table.issues > tbody > tr.issue'));
  if (!rows.length) return;

  tree.dataset.hideClosedSubtasksInitialized = 'true';

  const style = document.createElement('style');
  style.textContent = '#issue_tree tr.issue.view-customize-hidden-closed { display: none; }';
  document.head.appendChild(style);

  let hideClosed = false;

  const refresh = () => {
    rows.forEach((row) => {
      row.classList.toggle(
        'view-customize-hidden-closed',
        hideClosed && row.classList.contains('closed')
      );
    });
  };

  const addActions = (actions) => {
    if (actions.dataset.hideClosedSubtasksActions) return true;

    actions.dataset.hideClosedSubtasksActions = 'true';
    actions.insertAdjacentHTML('beforeend', `
      <span aria-hidden="true"> | </span>
      <a href="#" data-hide-closed-subtasks-action="hide">Hide closed</a>
      <span aria-hidden="true"> | </span>
      <a href="#" data-hide-closed-subtasks-action="show">Show closed</a>
      <span aria-hidden="true"> | </span>
    `);
    actions.addEventListener('click', (event) => {
      const action = event.target.closest('[data-hide-closed-subtasks-action]');
      if (!action) return;

      event.preventDefault();
      hideClosed = action.dataset.hideClosedSubtasksAction === 'hide';
      refresh();
    });
    return true;
  };

  const existingActions = tree.querySelector('.issue-tree-actions');
  if (existingActions) {
    addActions(existingActions);
  } else {
    const heading = tree.querySelector('p > strong')?.parentElement;
    if (heading) {
      const actions = document.createElement('span');
      actions.className = 'issue-tree-actions';
      heading.appendChild(actions);
      addActions(actions);
    }
  }

  refresh();
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeHideClosedSubtasks, {once: true});
} else {
  initializeHideClosedSubtasks();
}
