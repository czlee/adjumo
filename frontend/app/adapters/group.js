import ApplicationAdapter from './application';

export default ApplicationAdapter.extend({

  // Load in a file with two blank groups
  // Need to do this so findAll will return the cache rather than issue a lookup

  namespace: 'permanent',

});
