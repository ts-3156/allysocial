$(function () {
  $('[data-toggle="underline"]')
    .on('start.underline', function () {
      var elem = $(this);
      var selector = elem.data('target');
      $(selector).animate({'width': elem.css('width')}, {
        'easing': 'swing', complete: function () {
          setTimeout(function () {
            $(selector).animate({'width': 0}, {'easing': 'linear'});
          }, 100);
        }
      });
    });
});
