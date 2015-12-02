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
      console.log(body);
      res.json(body);
    }
  });

  // request(url, function (error, response, body) {
  //   if (!error && response.statusCode == 200) {
  //     var info = JSON.parse(body)
  //     res.send(info);
  //     // res.send('{         \
  //     //     "debates": 10,  \
  //     //     "round":"7",    \
  //     //});
  //   }
  // });

});

module.exports = router;
