import {Logger} from './logger';

var logger = new Logger(process.env.RAILS_ENV);

var nameRegexp = /^[\w_]{1,20}$/;

function screenNameToUid(screenName, done) {
  if (!screenName.match(nameRegexp)) {
    return;
  }

  var fetch = function (retryCount) {
    if (retryCount >= 5) {
      return;
    }

    var url = '/api/twitter_users'; // api_twitter_users_path
    $.get(url, {screen_name: screenName}).done(done).fail(function (xhr) {
      if (xhr.status === 404) {
        setTimeout(function () {
          fetch(++retryCount);
        }, Math.pow(2, retryCount) * 1000);
      }
    });
  };

  fetch();
}

class SearchLabel {
  constructor(url, form) {
    this.url = url;
    this.form = form;
    this.elem = $('#search-label');
    this.datalist = $('#search-label-options');

    this.elem.on('keypress', function (e) {
      if (e.keyCode === 13) { // Enter key
        form.search();
      }
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
    logger.log('datalist', options);
    this.datalist.empty();

    options.forEach(function (option) {
      var tag = $('<option/>', {value: option.label, text: option.label});
      this.datalist.append(tag);
    }, this);

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
    if (this.value() !== option.value) {
      this.form.resetState('label selected');
      this.elem.val(option.value);
      this.form.search(function () {
        $([document.documentElement, document.body]).animate({
          scrollTop: $('#search-response-anchor').offset().top
        });
      });
    }
  }

  setExtraCounts(extra) {
    $('label[for="category-friends"] .count').text(extra.friends);
    $('label[for="category-followers"] .count').text(extra.followers);
    $('label[for="category-one_sided_friends"] .count').text(extra.one_sided_friends);
    $('label[for="category-one_sided_followers"] .count').text(extra.one_sided_followers);
    $('label[for="category-mutual_friends"] .count').text(extra.mutual_friends);
    $('label[for="type-job"] .count').text(extra.jobs_count);
    $('label[for="type-location"] .count').text(extra.locations_count);
    $('label[for="type-url"] .count').text(extra.urls_count);
    $('label[for="type-keyword"] .count').text(extra.keywords_count);

    if (extra.limit_reached) {
      $('.limit-reached-help').find('.user').text(this.form.screenName()).end().show();
    } else {
      $('.limit-reached-help').hide();
    }
  }

  fetchOptions(callback) {
    screenNameToUid(this.form.screenName(), function (res) {
      var params = {
        category: this.form.category(),
        type: this.form.type(),
        uid: res.user.uid
      };
      $.get(this.url, params).done(function (data) {
        this.setOptions(data.options);
        this.setQuickSelectBadges(data.quick_select);
        this.setExtraCounts(data.extra);
        if (callback) {
          callback();
        }
      }.bind(this));
    }.bind(this));
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

  value() {
    return this.elem.val();
  }

  clearValue() {
    this.elem.val('');
  }

  removeCount() {
    var val = this.elem.val().replace(/ \(\d+\)$/, '');
    this.elem.val(val);
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
      self.search();
      return false;
    });

    $('#search-sort').on('change', this.switchSort.bind(this));
    $('#search-filter').on('change', this.switchFilter.bind(this));

    $('.search-response-title')
      .find('.category').on('click', function () {
      $('[data-target="#search-category-underline"]').trigger('start.underline');
    }).end()
      .find('.type').on('click', function () {
      $('[data-target="#search-type-underline"]').trigger('start.underline');
    }).end()
      .find('.label').on('click', function () {
      $('[data-target="#search-label-underline"]').trigger('start.underline');
    }).end();
  }

  setSearchLabel(obj) {
    this.searchLabel = obj;
    this.searchLabel.onChange(this.switchLabel.bind(this));
  }

  resetState(reason) {
    logger.log('Reset state:', reason);
    $('.search-response-title').hide();
    this.responseContainer.empty();
    this.searchLabel.setNeutral();
    this.lastUid = null;
    this.currentSize = 0;
  }

  switchUser() {
    this.resetState('switch user');
    this.searchLabel.clearValue();
    this.searchLabel.fetchOptions();
  }

  switchCategory() {
    this.resetState('switch category');
    this.searchLabel.clearValue();
    this.searchLabel.fetchOptions();
  }

  switchType() {
    this.resetState('switch type');
    this.searchLabel.clearValue();
    this.searchLabel.fetchOptions();
  }

  switchLabel() {
    this.resetState('switch label');
    this.searchLabel.removeCount();
    this.searchLabel.fetchOptions();
  }

  switchSort() {
    this.resetState('switch sort');
    if (this.label().length > 0) {
      this.search();
    }
  }

  switchFilter() {
    this.resetState('switch filter');
    if (this.label().length > 0) {
      this.search();
    }
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
    return this.searchLabel.value();
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
    if (!users || users.length === 0) {
      if (this.lastUid) {
        if (this.i18n['payment_required']) {
          this.responseContainer.append(this.i18n['payment_required']);
        }
      } else {
        this.resetState('no results found');
        this.showErrorMessage(this.i18n['no_results_found']);
      }
    } else {
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
    var img = $('<img/>', {src: 'ajax-loader.gif', loading: 'lazy', class: 'ml-1'});
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
      this.showErrorMessage('Please specify correct [screenName]');
      return;
    }

    if (category !== 'friends' && category !== 'followers' && category !== 'one_sided_friends' && category !== 'one_sided_followers' && category !== 'mutual_friends') {
      logger.warn('Invalid category', category);
      this.resetState('Invalid category');
      this.showErrorMessage('Please specify correct [category]');
      return;
    }

    if (type !== 'job' && type !== 'location' && type !== 'url' && type !== 'keyword') {
      logger.warn('Invalid type', type);
      this.resetState('Invalid type');
      this.showErrorMessage('Please specify correct [type]');
      return;
    }

    if (!label || label.length === 0) {
      logger.warn('Invalid label', label);
      this.resetState('Invalid label');
      this.showErrorMessage(this.i18n['specify_correct_label']);
      this.searchLabel.setInvalid();
      return;
    }

    screenNameToUid(screenName, function (res) {
      var user = res.user;

      $('.search-response-title').show()
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

      $.get(self.url, params).done(function (res) {
        logger.log('response', res);
        self.appendSearchResponse(res.users);
        if (callback) {
          callback();
        }
      });
    });
  }

  showErrorMessage(message) {
    this.responseContainer.empty().html(message).hide().fadeIn(500);
  }
}

export {SearchLabel, SearchForm};
