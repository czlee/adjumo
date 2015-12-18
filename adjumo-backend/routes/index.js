var express = require('express');
var router = express.Router();
var fs = require('fs');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Adjumo' });
});

router.post('/allocation-configs/', function(req, res) {
  console.log('posting an allocation config'); // populated!
  console.log(req.body); // populated!
  fs.writeFile('data/allocation-config.json', JSON.stringify(req.body, null, 4), function(err){
    if (err) throw err;
    console.log('File saved!');
  })
  res.send("ok");
  res.end();
})

router.post('/debate-importances/', function(req, res) {
  console.log('posting debate importances'); // populated!
  console.log(req.body); // populated!
  fs.writeFile('data/debate-importances.json', JSON.stringify(req.body, null, 4), function(err){
    if (err) throw err;
    console.log('File saved!');
  })
  res.send("ok");
  res.end();
})


// OLD

// router.get('/importround', function(req, res, next) {

//   // Poll a particular URL to get the JSON response
//   console.log('importing a round');

//   var url = 'http://0.0.0.0:3000/tabbie-test.json';
//   var request = require('request');

//   request(url, function (error, response, body) {
//     if (!error && response.statusCode == 200) {

//       //var parsedImport = JSON.parse(body);
//       res.send(JSON.parse(body));
//             res.json({ message: 'Bear created!' });

//     } else {
//       console.log('failed to import a round');
//     }
//   });

// });

// router.get('/room_importance/:parameter', function(req, res, next) {

//   // Import the relevant script
//   var julia = require('node-julia');
//   julia.exec('include','julia/test.jl');

//   // Call into the julia script
//   var room_value = julia.exec('testfunction', parseInt(req.params.parameter));

//   res.setHeader('Content-Type', 'application/json');
//   res.json({ importance: room_value });

// });

module.exports = router;