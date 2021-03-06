import {Logger} from './logger';
import {Chart} from './chart';

var logger = new Logger(process.env.RAILS_ENV);

var nameRegexp = /^[\w_]{1,20}$/;

function extractErrorMessage(xhr, textStatus, errorThrown) {
  var message;
  try {
    message = JSON.parse(xhr.responseText)['message'];
  } catch (e) {
    logger.error(e);
  }
  if (!message) {
    message = xhr.status + ' (' + errorThrown + ')';
  }
  return message;
}

function showErrorMessage(message) {
  if (message === 'specify_correct_label_message') {
    $('#specify-correct-label-message').show();
  } else if (message === 'no_results_found_message') {
    $('#no-results-found-message').show();
  } else {
    var container = $('#search-response-error');
    if (container.data('length') !== message.length) {
      container.empty().html(message).hide().fadeIn(500).data('length', message.length);
    }
  }
}

function hideErrorMessage() {
  $('#search-response-error').empty();
  $('#specify-correct-label-message').hide();
  $('#no-results-found-message').hide();
}

function exponentialBackoff(num) {
  return Math.max(20, Math.pow(2, num) * 1000);
}

function screenNameToUid(screenName, done) {
  if (!screenName.match(nameRegexp)) {
    return;
  }

  var fetch = function (retryCount) {
    if (retryCount >= 10) {
      return;
    }

    var url = '/api/twitter_users'; // api_twitter_users_path
    $.get(url, {screen_name: screenName}).done(function (res, _, xhr) {
      if (xhr.status === 202) { // Accepted
        showErrorMessage(res.message);
        setTimeout(function () {
          fetch(++retryCount);
        }, exponentialBackoff(retryCount));
      } else {
        done(res);
      }
    }).fail(function (xhr, textStatus, errorThrown) {
      var message = extractErrorMessage(xhr, textStatus, errorThrown);
      showErrorMessage(message);
      scrollToTop();
    });
  };

  fetch(0);
}

function scrollToTop() {
  $([document.documentElement, document.body]).animate({
    scrollTop: $('#search-response-anchor').offset().top
  });
}

class SearchLabel {
  constructor(url, form) {
    this.url = url;
    this.form = form;
    this.elem = $('#search-label');
    var self = this;

    this.elem.on('keypress', function (e) {
      if (e.keyCode === 13) { // Enter key
        form.search(scrollToTop);
      }
    }).on('focus', function () {
      $(this).autocomplete('search');
    }).on('autocompleteselect', function () {
      $(this).trigger('change');
    });

    $('#clear-search-label').on('click', function () {
      self.setValue('');
      self.elem.focus();
    });
  }

  updatePlaceholder() {
    var value;
    var type = this.form.type();

    if (type === 'job' || type === 'location' || type === 'url' || type === 'keyword') {
      value = this.elem.data('placeholder-' + type);
    } else {
      value = this.elem.data('placeholder');
    }
    this.elem.attr('placeholder', value);
  }

  setOptions(options) {
    this.elem.autocomplete({source: options, minLength: 0});
    this.updatePlaceholder();
    this.blink();
  }

  setQuickSelectBadges(options) {
    $('#quick-select a').text('');
    options.forEach(function (option, i) {
      var btn = $('#quick-select a:eq(' + i + ')');
      var self = this;
      btn.text(option.label).off('click').on('click', function () {
        self.selectBadge($(this), option);
        return false;
      });
    }, this);
  }

  selectBadge(btn, option) {
    if (this.getValue() !== option.value) {
      this.form.resetState('label selected');
      this.setValue(option.value);
      this.form.search(scrollToTop);
    }
  }

  setExtraCounts(extra) {
    $('label[for="category-friends"] .count').text(extra.friends_s);
    $('label[for="category-followers"] .count').text(extra.followers_s);
    $('label[for="category-one_sided_friends"] .count').text(extra.one_sided_friends_s);
    $('label[for="category-one_sided_followers"] .count').text(extra.one_sided_followers_s);
    $('label[for="category-mutual_friends"] .count').text(extra.mutual_friends_s);
    $('label[for="type-job"] .count').text(extra.jobs_count);
    $('label[for="type-location"] .count').text(extra.locations_count);
    $('label[for="type-url"] .count').text(extra.urls_count);
    $('label[for="type-keyword"] .count').text(extra.keywords_count);
  }

  drawChart(data) {
    if (this.chart) {
      this.chart.destroy();
    }
    this.chart = new Chart('chart-container', data.categories, data.series);
    this.chart.draw();
  }

  fetchOptions(callback) {
    var self = this;

    var fetch = function (uid, retryCount) {
      if (retryCount >= 5) {
        return;
      }

      var params = {
        category: self.form.category(),
        type: self.form.type(),
        uid: uid
      };

      $.get(self.url, params).done(function (data, _, xhr) {
        if (xhr.status === 202) { // Accepted
          showErrorMessage(data.message);
          setTimeout(function () {
            fetch(uid, ++retryCount);
          }, exponentialBackoff(retryCount));
        } else {
          self.setOptions(data.options);
          self.setQuickSelectBadges(data.quick_select);
          self.setExtraCounts(data.extra);
          self.drawChart(data.chart);
          if (callback) {
            callback();
          }
        }
      }).fail(function (xhr, textStatus, errorThrown) {
        var message = extractErrorMessage(xhr, textStatus, errorThrown);
        showErrorMessage(message);
        scrollToTop();
      });
    };

    screenNameToUid(this.form.screenName(), function (res) {
      fetch(res.user.uid, 0);
    });
  }

  setNeutral() {
    this.elem.removeClass('is-invalid').removeClass('is-valid');
  }

  setValid() {
    this.setNeutral();
    this.elem.addClass('is-valid');
  }

  setInvalid() {
    this.setNeutral();
    this.elem.addClass('is-invalid');
    $('[data-target="#search-label-underline"]').trigger('start.underline');
  }

  blink() {
    this.setValid();
    var self = this;
    setTimeout(function () {
      self.setNeutral();
    }, 1000);
  }

  getValue() {
    return this.elem.val();
  }

  setValue(val) {
    this.elem.val(val);
  }

  setQuickSelectValue() {
    var val = $('#quick-select a:eq(0)').text();
    this.setValue(val);
    this.removeCountSuffix();
  }

  removeCountSuffix() {
    var val = this.getValue().replace(/ \(\d+\)$/, '');
    this.setValue(val);
  }

  onChange(fn) {
    this.elem.on('change', fn);
  }
}

class SearchForm {
  constructor(url, i18n) {
    this.url = url;
    this.lastUid = null;
    this.currentSize = 0;
    this.i18n = i18n;
    this.responseContainer = $('#search-response');
    var self = this;

    $('#search-user').on('change', this.switchUser.bind(this));
    $("input[name='category']").on('change', this.switchCategory.bind(this));
    $("input[name='type']").on('change', this.switchType.bind(this));

    $('#reduced-display-check').on('change', function () {
      if ($(this).prop('checked')) {
        self.responseContainer.find('.search-response-user-container').trigger('compress.user');
      } else {
        self.responseContainer.find('.search-response-user-container').trigger('expand.user');
      }
    });

    $('#search-submit').on('click', function () {
      self.search(scrollToTop);
      return false;
    });

    $('#search-sort').on('change', this.switchSort.bind(this));
    $('#search-filter').on('change', this.switchFilter.bind(this));

    $('[href="#search-category-anchor"]').on('click', function () {
      $('[data-target="#search-category-underline"]').trigger('start.underline');
    });
    $('[href="#search-type-anchor"]').on('click', function () {
      $('[data-target="#search-type-underline"]').trigger('start.underline');
    });
    $('[href="#search-label-anchor"]').on('click', function () {
      $('[data-target="#search-label-underline"]').trigger('start.underline');
    });
  }

  setSearchLabel(obj) {
    this.searchLabel = obj;
    this.searchLabel.onChange(this.switchLabel.bind(this));
  }

  resetState(reason) {
    logger.log('Reset state:', reason);
    // $('#search-response-title').hide();
    this.responseContainer.empty();
    this.searchLabel.setNeutral();
    this.lastUid = null;
    this.currentSize = 0;
  }

  switchUser() {
    this.resetState('switch user');
    this.searchLabel.fetchOptions(this.search.bind(this));
  }

  switchCategory() {
    this.resetState('switch category');
    this.searchLabel.fetchOptions(this.search.bind(this));
  }

  switchType() {
    this.resetState('switch type');
    this.searchLabel.fetchOptions(function () {
      this.searchLabel.setQuickSelectValue();
      this.search(scrollToTop);
    }.bind(this));
  }

  switchLabel() {
    this.resetState('switch label');
    this.searchLabel.removeCountSuffix();
    this.search();
  }

  switchSort() {
    this.resetState('switch sort');
    this.search(scrollToTop);
  }

  switchFilter() {
    this.resetState('switch filter');
    this.search(scrollToTop);
  }

  screenName() {
    return $('#search-user').val().replace(/^@/, '');
  }

  category() {
    return $("input[name='category']:checked").val();
  }

  categoryLabel() {
    return $("input[name='category']:checked").data('label');
  }

  type() {
    return $("input[name='type']:checked").val();
  }

  typeLabel() {
    return $("input[name='type']:checked").data('label');
  }

  label() {
    return this.searchLabel.getValue();
  }

  sort() {
    return $('#search-sort').val();
  }

  filter() {
    return $('#search-filter').val();
  }

  renderUser(user) {
    if (user.description) {
      user.description = user.description.replace('\n', '<br>').replace(/https?:\/\//g, '');
      user.description = window.linkifyHtml(user.description, {defaultProtocol: 'https'});
    }
    user.index_number = ++this.currentSize;

    var template = $('#search-response-user-template').html(); // TODO instance variable
    var rendered = $(Mustache.render(template, user));
    rendered.find('img[data-src]').each(function () {
      var img = $(this);
      img.attr('src', img.attr('data-src'));
    });
    return rendered;
  }

  appendSearchResponse(users) {
    var chart = $('#chart-container');

    if (!users || users.length === 0) {
      if (this.lastUid) {
        if (this.i18n['payment_required']) {
          this.responseContainer.append(this.i18n['payment_required']);
        }
      } else {
        this.resetState('no results found');
        chart.hide();
        showErrorMessage('no_results_found_message');
      }
    } else {
      chart.show();
      var container = $('<div/>', {style: 'display: none;'});
      var loader = this.createLoader(this.loadNextUsers.bind(this));

      users.forEach(function (user) {
        container.append(this.renderUser(user));
      }, this);
      this.responseContainer.append(container);
      $('#reduced-display-check').trigger('change');
      container.fadeIn(500);
      this.responseContainer.append(loader);

      this.lastUid = users[users.length - 1].uid;
    }
  }

  loadNextUsers(e) {
    var self = this;
    setTimeout(function () {
      self.search(function () {
        $(e.target).remove();
      });
    }, 1000);
  }

  createLoader(callback) {
    var elem = $('<div/>', {text: this.i18n['loading']}).lazyload().one('appear', callback);
    var img = $('<img/>', {src: '/ajax-loader.gif', loading: 'lazy', class: 'ml-1'});
    return elem.append(img);
  }

  search(callback) {
    var category = this.category();
    var type = this.type();
    var label = this.label();
    var screenName = this.screenName();
    var sort = this.sort();
    var filter = this.filter();
    var self = this;

    if (!screenName.match(nameRegexp)) {
      logger.warn('Invalid screenName', screenName);
      this.resetState('Invalid screenName');
      showErrorMessage('Please specify correct [screenName]');
      return;
    }

    if (category !== 'friends' && category !== 'followers' && category !== 'one_sided_friends' && category !== 'one_sided_followers' && category !== 'mutual_friends') {
      logger.warn('Invalid category', category);
      this.resetState('Invalid category');
      showErrorMessage('Please specify correct [category]');
      return;
    }

    if (type !== 'job' && type !== 'location' && type !== 'url' && type !== 'keyword') {
      logger.warn('Invalid type', type);
      this.resetState('Invalid type');
      showErrorMessage('Please specify correct [type]');
      return;
    }

    if (!label || label.length === 0) {
      logger.warn('Invalid label', label);
      this.resetState('Invalid label');
      showErrorMessage('specify_correct_label_message');
      this.searchLabel.setInvalid();
      return;
    }

    screenNameToUid(screenName, function (res) {
      var user = res.user;

      $('#search-response-title').show()
        .find('.user').text(screenName).end()
        .find('.category').text(self.categoryLabel()).end()
        .find('.type').text(self.typeLabel()).end()
        .find('.label').text(label);

      var params = {
        category: category,
        type: type,
        label: label,
        uid: user.uid,
        sort: sort,
        filter: filter,
        last_uid: self.lastUid,
        current_size: self.currentSize
      };
      logger.log('request', params);
      ahoy.track('search', params);

      $.get(self.url, params).done(function (res) {
        logger.log('response', res);
        hideErrorMessage();
        self.appendSearchResponse(res.users);
        if (callback) {
          callback();
        }
      });
    });
  }
}

export {SearchLabel, SearchForm};
