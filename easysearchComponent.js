import {BaseComponent} from 'meteor/easy:search'

/**
 * The InputComponent lets you search through configured indexes.
 *
 * @type {AreaComponent}
 */
EasySearch.AreaComponent = class AreaComponent extends BaseComponent {
  /**
   * Setup input onCreated.
   */
  onCreated() {
    super.onCreated(...arguments);

    this.search(this.inputAttributes().value);

    // create a reactive dependency to the cursor
    this.debouncedSearch = _.debounce((searchString) => {
      searchString = searchString.trim();

      if (this.searchString !== searchString) {
        this.searchString = searchString;

        this.eachIndex((index, name) => {
          index.getComponentDict(name).set('currentPage', 1);
        });

        this.search(searchString);
      }

    }, this.options.timeout);
  }

  /**
   * Event map.
   *
   * @returns {Object}
   */
  events() {
    return [{
      'onSearch': function (e, data) {
        console.log('search', data);
        this.debouncedSearch(data);
      }
    }];
  }

  /**
   * Return the attributes to set on the input (class, id).
   *
   * @returns {Object}
   */
  inputAttributes() {
    return _.defaults({}, this.getData().attributes, AreaComponent.defaultAttributes);
  }

  /**
   * Return the default attributes.
   *
   * @returns {Object}
   */
  static get defaultAttributes() {
    return {
      value: ''
    };
  }

  /**
   * Return the default options.
   *
   * @returns {Object}
   */
  get defaultOptions() {
    return {
      timeout: 50
    };
  }
};

EasySearch.AreaComponent.register('EasySearch.Area');