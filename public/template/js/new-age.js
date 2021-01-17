$(function () {
  var mainNav = $('#mainNav');
  var lastScrollTop = 0;

  // Collapse Navbar
  var navbarCollapse = function () {
    if (mainNav.offset().top > 0) {
      mainNav.addClass("navbar-shrink");
    } else {
      mainNav.removeClass("navbar-shrink");
    }

    var st = $(this).scrollTop();
    if (st > lastScrollTop) { // Down
      mainNav.hide();
    } else { // Up
      mainNav.show();
    }
    lastScrollTop = st;
  };
  // Collapse now if page is not at top
  navbarCollapse();
  // Collapse the navbar when page is scrolled
  $(window).scroll(navbarCollapse);
});
