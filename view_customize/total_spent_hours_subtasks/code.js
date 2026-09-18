const initializeSubtaskSpentHours = () => {
  const tree = document.getElementById('issue_tree');
  const table = tree?.querySelector('table.issues');
  if (!table || table.dataset.spentHoursInitialized) return;

  const style = document.createElement('style');
  style.textContent = '#issue_tree th.done_ratio, #issue_tree td.done_ratio { display: none; }';
  document.head.appendChild(style);

  const rows = Array.from(table.querySelectorAll('tbody > tr.issue'));
  if (!rows.length) return;

  table.dataset.spentHoursInitialized = 'true';

  const issueIds = rows
    .map((row) => row.id.match(/^issue-(\d+)$/)?.[1])
    .filter(Boolean);

  if (!issueIds.length) return;

  const assigneeHeader = table.querySelector('thead th.assigned_to');
  const progressHeader = table.querySelector('thead th.done_ratio');
  const headerAnchor = assigneeHeader || progressHeader;
  if (headerAnchor) {
    const header = document.createElement('th');
    header.className = 'total_spent_hours';
    header.textContent = 'Spent time';
    headerAnchor.after(header);
  }

  rows.forEach((row) => {
    const assigneeCell = row.querySelector('td.assigned_to');
    const progressCell = row.querySelector('td.done_ratio');
    const cellAnchor = assigneeCell || progressCell;
    if (!cellAnchor) return;

    const cell = document.createElement('td');
    cell.className = 'total_spent_hours';
    cell.textContent = '…';
    cellAnchor.after(cell);
  });

  const headers = {Accept: 'application/json'};
  const apiKey = window.ViewCustomize?.context?.user?.apiKey;
  if (apiKey) headers['X-Redmine-API-Key'] = apiKey;

  const depthOf = (row) => {
    const match = row.className.match(/(?:^|\s)idnt-(\d+)(?:\s|$)/);
    return match ? Number(match[1]) : 0;
  };

  const branchRows = new Set(rows.filter((row, index) => {
    const nextRow = rows[index + 1];
    return nextRow && depthOf(nextRow) > depthOf(row);
  }));

  Promise.all(issueIds.map((issueId) =>
    fetch(`/issues/${issueId}.json`, {headers})
      .then((response) => {
        if (!response.ok) throw new Error(`Issue API returned ${response.status} for ${issueId}`);
        return response.json();
      })
      .then((data) => data.issue)
  ))
    .then((issues) => {
      const issueData = new Map(issues.map((issue) => [String(issue.id), issue]));
      const directHours = new Map(
        issues.map((issue) => [String(issue.id), Number(issue.spent_hours || 0)])
      );
      const formatHours = (hours) => `${Number(hours || 0).toFixed(2)} h`;

      rows.forEach((row, index) => {
        const issueId = row.id.replace(/^issue-/, '');
        const cell = row.querySelector('td.total_spent_hours');
        if (!cell) return;

        const directValue = directHours.get(issueId) || 0;
        const currentDepth = depthOf(row);
        let totalValue = Number(issueData.get(issueId)?.total_spent_hours);

        if (!Number.isFinite(totalValue)) {
          totalValue = directValue;
          for (let childIndex = index + 1; childIndex < rows.length; childIndex += 1) {
            if (depthOf(rows[childIndex]) <= currentDepth) break;
            const childId = rows[childIndex].id.replace(/^issue-/, '');
            totalValue += directHours.get(childId) || 0;
          }
        }

        cell.replaceChildren(document.createTextNode(formatHours(directValue)));

        if (branchRows.has(row)) {
          cell.append(document.createTextNode(' ('));
          const totalLink = document.createElement('a');
          totalLink.href = `/time_entries?issue_id=~${issueId}`;
          totalLink.textContent = `Total: ${formatHours(totalValue)}`;
          cell.append(totalLink, document.createTextNode(')'));
        }
      });
    })
    .catch((error) => {
      console.warn('Unable to load spent time for subtasks', error);
      table.querySelectorAll('td.total_spent_hours').forEach((cell) => {
        cell.textContent = '—';
      });
    });
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeSubtaskSpentHours, {once: true});
} else {
  initializeSubtaskSpentHours();
}
