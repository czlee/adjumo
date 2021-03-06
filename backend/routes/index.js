var express = require('express');
var router = express.Router();
var fs = require('fs');
var julia = require('node-julia');
julia.eval('push!(LOAD_PATH, \"../julia\")')
var adjumoJulia = julia.import('Adjumo')

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Adjumo' });
});


/* GET home page. */
router.get('/data/adjudicators.json/:id', function(req, res, next) {
  console.log('Received a GET for a adjudicator that didnt exist returning dummy');
  var dummyID = req.params.id;
  var dummyadj = {
    data:
      {
        attributes: {
          name: "Dummy Adjudicator",
          gender: 1,
          ranking: 8,
          language: 0,
          regions: [0]
        },
        id: dummyID,
        type: "adjudicator",
        relationships: {
          institution: {
            data: {
              id: 1840,
              type: "institution"
            }
          }
        }
      }
    };
  // console.log(dummyadj),
  res.setHeader('Content-Type', 'application/json');
  res.send(JSON.stringify(dummyadj));
});

router.post('/allocation-configs/', function(req, res) {
  //console.log('posting an allocation config');

  // THE JSON file-write option
  fs.writeFile('data/allocation-config.json', JSON.stringify(req.body, null, 2), function(err){
    if (err) throw err;
    console.log('Allocation config file saved!');
  })

  // // The pass directly to Juila option
  // julia.exec('include','../julia/test.jl');
  // var dummyvalue = julia.exec('pretendAllocation',
  //   parseInt(req.body.teamhistory),
  //   parseInt(req.body.adjhistory),
  //   parseInt(req.body.teamconflict),
  //   parseInt(req.body.adjconflict),
  //   parseInt(req.body.quality),
  //   parseInt(req.body.regional),
  //   parseInt(req.body.language),
  //   parseInt(req.body.gender)
  //   parseInt(req.body.alpha)
  // );
  // console.log('dummyvalue=' + dummyvalue);

  res.send("ok");
  res.end();

}),


router.post('/debate-scores/', function(req, res) {

  console.log('posted debate scores got');
  // console.log(req.body);

  var adjs = req.body.adjudicators;
  var teams = req.body.teams;

  var json = JSON.stringify(req.body); // PIPE this into the proper function

  var result = adjumoJulia.scoresfordisplay(json);
  console.log(result);
  var scores = {
    panelQuality: result[0],
    regionalRepresentation: result[1],
    languageRepresentation: result[2],
    genderRepresentation: result[3],
  }
  res.setHeader('Content-Type', 'application/json');
  res.send(JSON.stringify(scores));

}),

router.post('/groups/', function(req, res) {
  console.log('posted groups:');
  console.log(req.body);
  fs.writeFile('data/grouped-adjs.json', JSON.stringify(req.body, null, 2), function(err){
    if (err) throw err;
    console.log('Grouped adjs file saved!');
  })
  res.send("ok");
  res.end();
}),


router.post('/blocks/', function(req, res) {
  console.log('posted blocks:');
  console.log(req.body);
  fs.writeFile('data/blockedadjs.json', JSON.stringify(req.body, null, 2), function(err){
    if (err) throw err;
    console.log('Blocked adjs file saved!');
  })
  res.send("ok");
  res.end();
}),

router.post('/locks/', function(req, res) {
  console.log('posted locks:');
  console.log(req.body);
  fs.writeFile('data/lockedadjs.json', JSON.stringify(req.body, null, 2), function(err){
    if (err) throw err;
    console.log('Locked adjs file saved!');
  })
  res.send("ok");
  res.end();
}),

router.post('/debate-importances/', function(req, res) {
  // console.log('posting debate importances'); // populated!
  // console.log(req.body); // populated!
  fs.writeFile('data/debate-importances.json', JSON.stringify(req.body, null, 2), function(err){
    if (err) throw err;
    console.log('Debate importances file saved!');
  })
  res.send("ok");
  res.end();
}),



router.post('/tabbie2-test/', function(req, res) {
  // console.log(req.body);
  fs.writeFile('data/tabbie2-test.json', JSON.stringify(req.body.exportData, null, 2), function(err){
    if (err) throw err;
    console.log('Tabbie 2 export file saved!');
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