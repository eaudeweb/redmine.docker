const initializeQuickSearchShortcut = () => {
  const searchInput = document.getElementById('q');
  const projectJump = document.getElementById('project-jump');
  const projectTrigger = projectJump?.querySelector('.drdn-trigger');
  const projectSearch = document.getElementById('projects-quick-search');
  if ((!searchInput && !projectJump) || document.documentElement.dataset.quickSearchShortcutInitialized) return;

  document.documentElement.dataset.quickSearchShortcutInitialized = 'true';

  searchInput?.setAttribute('title', 'Ctrl+E to focus');
  projectTrigger?.setAttribute('title', 'Ctrl+P to focus');
  projectSearch?.setAttribute('title', 'Ctrl+P to focus');

  window.addEventListener('keydown', (event) => {
    if (!event.ctrlKey || event.altKey || event.metaKey) return;

    if (event.code === 'KeyE' && searchInput) {
      event.preventDefault();
      searchInput.focus();
      searchInput.select();
      return;
    }

    if (event.code === 'KeyP' && projectJump) {
      event.preventDefault();

      const trigger = projectJump.querySelector('.drdn-trigger');
      const dropdown = projectJump.querySelector('.drdn-content');
      const isOpen = projectJump.classList.contains('expanded') ||
        dropdown?.classList.contains('expanded') ||
        (dropdown && getComputedStyle(dropdown).display !== 'none');

      if (!isOpen) trigger?.click();

      window.setTimeout(() => {
        projectSearch?.focus();
        projectSearch?.select();
      }, 0);
    }
  }, true);
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeQuickSearchShortcut, {once: true});
} else {
  initializeQuickSearchShortcut();
}
