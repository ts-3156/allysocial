(function () {
  try {
    var height = window.getComputedStyle(document.getElementById('mainNav')).height;
    document.getElementById('new-age-navbar').style.height = height;
  } catch (e) {
    // Do nothing
  }
})();

$('.navbar-brand').on('click', function () {
  if ($(window).scrollTop() === 0) {
    var url = '/?via=brand'; // root_path(via: 'brand')
    window.location.href = url;
  } else {
    $([document.documentElement, document.body]).animate({scrollTop: 0});
  }
});
