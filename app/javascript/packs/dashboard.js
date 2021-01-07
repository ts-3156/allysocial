import {Logger} from './logger';

var logger = new Logger(process.env.RAILS_ENV);

class SearchLabel {
  constructor(url, form) {
    this.url = url;
    this.form = form;
    this.elem = $('#search-label');
    this.datalist = $('#search-label-options');

    $("input[name='category']").on('click', this.fetchOptions.bind(this));
    $("input[name='type']").on('click', this.fetchOptions.bind(this));

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
    var self = this;

    options.forEach(function (option) {
      var tag = $('<option/>', {value: option.label, text: option.label});
      self.datalist.append(tag);
    });

    this.updatePlaceholder();
    this.blink();
  }

  setQuickSelect(options) {
    var self = this;
    $('#quick-select a').text('');
    options.forEach(function (option, i) {
      var btn = $('#quick-select a:eq(' + i + ')');
      btn.text(option.label).on('click', function () {
        self.form.resetState('label selected');
        self.elem.val(option.value);
        return false;
      });
    });
  }

  fetchOptions() {
    var category = this.form.category();
    var type = this.form.type();
    var self = this;

    $.get(this.url, {category: category, type: type}).done(function (res) {
      self.setOptions(res.options);
      self.setQuickSelect(res.quick_select);
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
    this.currentIndexNumber = 1;
    this.i18n = i18n;

    $("input[name='category']").on('change', this.switchCategory.bind(this));
    $("input[name='type']").on('change', this.switchType.bind(this));

    $('#show-details-check').on('change', function () {
      if ($(this).prop('checked')) {
        $('#search-response').find('.search-response-user-details').show();
      } else {
        $('#search-response').find('.search-response-user-details').hide();
      }
    });

    var self = this;
    $('#search-submit').on('click', function () {
      self.search();
      return false;
    });
  }

  setSearchLabel(obj) {
    this.searchLabel = obj;
    this.searchLabel.onChange(this.switchLabel.bind(this));
  }

  resetState(reason) {
    logger.log('Reset search state:', reason);
    $('.search-response-title').hide();
    $('#search-response').empty();
    this.searchLabel.setNeutral();
    this.lastUid = null;
    this.currentIndexNumber = 1;
  }

  switchCategory() {
    this.resetState('switch category');
    this.searchLabel.clearValue();
  }

  switchType() {
    this.resetState('switch type');
    this.searchLabel.clearValue();
  }

  switchLabel() {
    this.resetState('switch label');
    this.searchLabel.removeCount();
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

  appendSearchResponse(users) {
    if (!users || users.length === 0) {
      if (this.lastUid) {
        // Do nothing
      } else {
        this.resetState('no results found');
        $('#search-response').empty().html(this.i18n['no_results_found']).hide().fadeIn(500);
      }
    } else {
      var container = $('<div/>', {style: 'display: none;'});
      var template = $('#search-response-user-template').html(); // TODO instance variable
      var self = this;

      users.forEach(function (user) {
        // TODO Implement as a method
        if (user.description) {
          user.description = user.description.replace('\n', '<br>').replace(/https?:\/\//g, '');
          user.description = window.linkifyHtml(user.description, {defaultProtocol: 'https'});
        }
        user.index_number = self.currentIndexNumber++;
        var rendered = $(Mustache.render(template, user));
        rendered.find('img[data-src]').each(function () {
          var img = $(this);
          img.attr('src', img.attr('data-src'));
        });
        container.append(rendered);
      });
      if (!$('#show-details-check').prop('checked')) {
        container.find('.search-response-user-details').hide();
      }
      $('#search-response').append(container);
      container.fadeIn(500);
      $('#search-response').append($('<div/>', {text: 'Loading'}).lazyload().one('appear', function () {
        var elem = $(this);
        self.search(function () {
          elem.remove();
        });
      }));

      this.lastUid = users[users.length - 1].uid;
    }
  }

  search(callback) {
    var category = this.category();
    var type = this.type();
    var label = this.label();
    var limit = 10;
    var self = this;

    if (category !== 'friends' && category !== 'followers' && category !== 'one_sided_friends' && category !== 'one_sided_followers' && category !== 'mutual_friends') {
      logger.warn('Invalid category', category);
      this.resetState('Invalid category');
      $('#search-response').empty().text('Please specify correct [category]').hide().fadeIn(500);
      return;
    }

    if (type !== 'job' && type !== 'location' && type !== 'url' && type !== 'keyword') {
      logger.warn('Invalid type', type);
      this.resetState('Invalid type');
      $('#search-response').empty().text('Please specify correct [type]').hide().fadeIn(500);
      return;
    }

    if (!label || label.length === 0) {
      logger.warn('Invalid label', label);
      this.resetState('Invalid label');
      $('#search-response').empty().text(this.i18n['specify_correct_label']).hide().fadeIn(500);
      self.searchLabel.setInvalid();
      return;
    }

    $('.search-response-title').show()
      .find('.category').text(this.categoryLabel()).end()
      .find('.type').text(this.typeLabel()).end()
      .find('.label').text(label);

    var params = {category: category, type: type, label: label, limit: limit, last_uid: this.lastUid};
    logger.log('request', params);

    $.get(this.url, params).done(function (res) {
      logger.log('response', res);
      self.appendSearchResponse(res.users);
      if (callback) {
        callback();
      }
    });
  }

}

export {SearchLabel, SearchForm};
