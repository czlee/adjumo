import ApplicationAdapter from './application';

export default ApplicationAdapter.extend({

  // Load in a file with no data
  // Need to do this so findAll will return the cache rather than issue a lookup

  namespace: 'permanent',

});
