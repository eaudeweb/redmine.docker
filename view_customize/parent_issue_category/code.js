const initializeParentIssueCategory = () => {
  const parentField = document.getElementById('issue_parent_issue_id');
  const categoryField = document.getElementById('issue_category_id');
  if (!parentField || !categoryField || parentField.dataset.parentCategoryInitialized) return;

  parentField.dataset.parentCategoryInitialized = 'true';

  const headers = {Accept: 'application/json'};
  const apiKey = window.ViewCustomize?.context?.user?.apiKey;
  if (apiKey) headers['X-Redmine-API-Key'] = apiKey;

  let requestNumber = 0;

  const syncCategory = () => {
    if (categoryField.value) return;

    const requestId = ++requestNumber;
    const parentId = parentField.value.trim().match(/^#?(\d+)$/)?.[1];
    if (!parentId) return;

    fetch(`/issues/${parentId}.json`, {headers})
      .then((response) => {
        if (!response.ok) throw new Error(`Issue API returned ${response.status}`);
        return response.json();
      })
      .then((data) => {
        if (requestId !== requestNumber || parentField.value.trim().match(/^#?(\d+)$/)?.[1] !== parentId) {
          return;
        }

        if (categoryField.value) return;

        const categoryId = data.issue?.category?.id;
        categoryField.value = categoryId ? String(categoryId) : '';
      })
      .catch((error) => {
        console.warn('Unable to load the parent issue category', error);
      });
  };

  parentField.addEventListener('input', syncCategory);
  parentField.addEventListener('change', syncCategory);

  if (window.jQuery) {
    window.jQuery(parentField).on('autocompleteselect', () => {
      // jQuery UI updates the input value immediately after this event.
      window.setTimeout(syncCategory, 0);
    });
  }

  syncCategory();
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeParentIssueCategory, {once: true});
} else {
  initializeParentIssueCategory();
}
