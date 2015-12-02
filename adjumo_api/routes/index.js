var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Adjumo' });
});

router.get('/importround', function(req, res, next) {

  // Poll a particular URL to get the JSON response
  console.log('importing a round');

  var url = 'http://0.0.0.0:3000/dummy.json';
  var request = require('request');

  request(url, function (error, response, body) {
    if (!error && response.statusCode == 200) {
      res.setHeader('Content-Type', 'application/json');
      res.json(body);
    }
  });

});

router.get('/room_importance/:parameter', function(req, res, next) {

  // Import the relevant script
  var julia = require('node-julia');
  julia.exec('include','julia/test.jl');

  // Call into the julia script
  var room_value = julia.exec('testfunction', parseInt(req.params.parameter));

  res.setHeader('Content-Type', 'application/json');
  res.json({ importance: room_value });

});

module.exports = router;
