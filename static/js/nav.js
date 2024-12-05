const navContainer = document.querySelector('nav');
const navMenu = document.querySelector('.navbar-nav');
const navLinks = document.querySelectorAll('.nav-link');

navLinks.forEach((navLink) => {
  navLink.addEventListener(
    'click',
    (e) => {
      navLink.classList.remove('active');

      //change tab on click
      navLinks.forEach((n) => {
        n.classList.remove('active');
      });
      navLink.classList.add('active');
    },
    false
  );
});

function navBarBoxShadow() {
  let navPosition = navContainer.offsetHeight;
  let windowPosition = window.pageYOffset;

  if (navPosition <= windowPosition) {
    navContainer.classList.add('nav-box-shadow');
  } else if (navPosition >= windowPosition) {
    navContainer.classList.remove('nav-box-shadow');
  } else {
    return;
  }
}

window.addEventListener('scroll', navBarBoxShadow);
