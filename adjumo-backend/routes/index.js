var express = require('express');
var router = express.Router();
var fs = require('fs');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Adjumo' });
});

// router.get('/allocationC-onfigs/1', function(req, res, next) {
//   console.log('getting config 1');
//   res.json(
//   {
//     "data":
//     [
//       {
//         "type": "allocation-config",
//         "id": 1,
//         "attributes": {
//           "teamhistory": 1,
//           "adjhistory": 1,
//           "teamconflict": 1,
//           "adjconflict": 1,
//           "quality": 1,
//           "regional": 1,
//           "language": 1,
//           "gender": 9,
//         }
//       }
//     ]
//   });
// });

// router.patch('/allocation-configs/1', function(req, res, next) {
//   console.log('patching config 1');
//   console.log(req.body);
//   console.log('___');
// })

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



router.get('/importround', function(req, res, next) {

  // Poll a particular URL to get the JSON response
  console.log('importing a round');

  var url = 'http://0.0.0.0:3000/tabbie-test.json';
  var request = require('request');

  request(url, function (error, response, body) {
    if (!error && response.statusCode == 200) {

      //var parsedImport = JSON.parse(body);
      res.send(JSON.parse(body));
            res.json({ message: 'Bear created!' });

    } else {
      console.log('failed to import a round');
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


// Modify a panel
// router.get('/debate/:parameter/panel', function(req, res, next) {

// });

