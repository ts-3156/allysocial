// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import * as ActiveStorage from "@rails/activestorage";
import "channels";

import ahoy from 'ahoy.js';
import {SearchLabel, SearchForm} from './dashboard';
import './underline';
import {Stripe} from './stripe';

window.ahoy = ahoy;
ahoy.trackAll();

window.SearchLabel = SearchLabel;
window.SearchForm = SearchForm;
window.MyStripe = Stripe;

Rails.start();
ActiveStorage.start();
