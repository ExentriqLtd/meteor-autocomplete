// Import Tinytest from the tinytest Meteor package.
import { Tinytest } from "meteor/tinytest";

// Import and rename a variable exported by autocomplete.js.
import { name as packageName } from "meteor/autocomplete";

// Write your tests here!
// Here is an example.
Tinytest.add('autocomplete - example', function (test) {
  test.equal(packageName, "autocomplete");
});
