import ApplicationAdapter from './application';

export default DS.JSONAPIAdapter.extend({

  suffix: '',
  //host: 'http://localhost:4200',
  namespace: '',
  // headers: {
  //   "Access-Control-Allow-Origin": '*',
  //   "Access-Control-Allow-Methods": 'GET, POST',
  //   "Access-Control-Allow-Headers": 'X-Requested-With,content-type, Authorization',
  //   }, // Security Bad

});
