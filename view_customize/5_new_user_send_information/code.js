const initializeNewUserSendInformation = () => {
  const checkbox = document.querySelector(
    'form input[name="send_information"], form #send_information'
  );
  if (!checkbox || checkbox.dataset.sendInformationPositionInitialized) return;

  const form = checkbox.closest('form');
  if (!form) return;

  const field = checkbox.closest('p, .field');
  const buttons = Array.from(form.querySelectorAll('p, .buttons'))
    .find((element) => element.querySelector('input[type="submit"]'));
  if (!field || !buttons || field === buttons || buttons.contains(field)) return;

  checkbox.dataset.sendInformationPositionInitialized = 'true';
  buttons.before(field);
};

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeNewUserSendInformation, {once: true});
} else {
  initializeNewUserSendInformation();
}
