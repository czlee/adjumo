export default function() {

  // Dummy data for mocking the json response
  this.get('/institutionsold/', function() {
    return {
      data: [
        {
          type: "institutions",
          id: 1,
          attributes: {
            name: "Victoria Wellington",
          },
          relationships: { "region": { "data": { "type": "region", "id": "1" } } }
        },{
          type: "institutions",
          id: 2,
          attributes: {
            name: "Auckland",
          },
          relationships: { "region": { "data": { "type": "region", "id": "2" } } }
        },{
          type: "institutions",
          id: 3,
          attributes: {
            name: "Melbourne",
          },
          relationships: { "region": { "data": { "type": "region", "id": "3" } } }
        },{
          type: "institutions",
          id: 4,
          attributes: {
            name: "USU",
          },
          relationships: { "region": { "data": { "type": "region", "id": "4" } } }
        },{
          type: "institutions",
          id: 5,
          attributes: {
            name: "HArvard",
          },
          relationships: { "region": { "data": { "type": "region", "id": "5" } } }
        },{
          type: "institutions",
          id: 6,
          attributes: {
            name: "Oxford",
          },
          relationships: { "region": { "data": { "type": "region", "id": "6" } } }
        },{
          type: "institutions",
          id: 7,
          attributes: {
            name: "ULU",
          },
          relationships: { "region": { "data": { "type": "region", "id": "7" } } }
        },{
          type: "institutions",
          id: 8,
          attributes: {
            name: "New South Wales",
          },
          relationships: { "region": { "data": { "type": "region", "id": "8" } } }
        },{
          type: "institutions",
          id: 9,
          attributes: {
            name: "Cambridge",
          },
          relationships: { "region": { "data": { "type": "region", "id": "9" } } }
        },{
          type: "institutions",
          id: 10,
          attributes: {
            name: "IIUM",
          },
          relationships: { "region": { "data": { "type": "region", "id": "10" } } }
        }
      ]
    }
  })

  this.get('/institutions/', function() {
    return {
      data: [{
        "attributes":{
          "name":"Copenhagen Business School (CBS)",
          "id":1804,
          "code":"Copenhangen",
          "region":9
        },
        "id":1804,
        "type":"institution"
      },
      {"attributes":{"name":"University of Technology Jamaica","id":9771,"code":"UT Jamaica","region":8},"id":9771,"type":"institution"},{"attributes":{"name":"University of Namibia","id":5375,"code":"Namibia","region":5},"id":5375,"type":"institution"},{"attributes":{"name":"Koc University","id":9416,"code":"Koc","region":3},"id":9416,"type":"institution"},{"attributes":{"name":"Universiti Malaysia Terengganu","id":6816,"code":"Terengganu","region":2},"id":6816,"type":"institution"},{"attributes":{"name":"Sun-Yat-Sen University","id":2030,"code":"Sun Yat Sen","region":1},"id":2030,"type":"institution"},{"attributes":{"name":"University of Technology Sydney (UTS)","id":9624,"code":"UT Sydney","region":6},"id":9624,"type":"institution"},{"attributes":{"name":"Aberystwyth University","id":9020,"code":"Aberystwyth","region":10},"id":9020,"type":"institution"},{"attributes":{"name":"University of Victoria","id":2922,"code":"Victoria Canada","region":7},"id":2922,"type":"institution"},{"attributes":{"name":"Premier University Chittagong","id":5708,"code":"Chittagong","region":4},"id":5708,"type":"institution"},{"attributes":{"name":"University of Pretoria (TUKS)","id":615,"code":"Pretoria","region":5},"id":615,"type":"institution"},{"attributes":{"name":"University of Botswana","id":3634,"code":"Botswana","region":5},"id":3634,"type":"institution"},{"attributes":{"name":"Universitas Padjadjaran","id":9456,"code":"Padjadjaran","region":2},"id":9456,"type":"institution"},{"attributes":{"name":"York University","id":8106,"code":"York","region":7},"id":8106,"type":"institution"},{"attributes":{"name":"University of Mostar","id":2345,"code":"Mostar","region":9},"id":2345,"type":"institution"},{"attributes":{"name":"International Islamic University Malaysia (IIUM)","id":5710,"code":"IIU Malaysia","region":2},"id":5710,"type":"institution"},{"attributes":{"name":"University of Western Australia (UWA)","id":2206,"code":"Western Australia","region":6},"id":2206,"type":"institution"},{"attributes":{"name":"National Taiwan University (NTU)","id":2502,"code":"Natl Taiwan","region":1},"id":2502,"type":"institution"},{"attributes":{"name":"University of Zimbabwe","id":33,"code":"Zimbabwe","region":5},"id":33,"type":"institution"},{"attributes":{"name":"Premier University Chittagong","id":185,"code":"Chittagong","region":4},"id":185,"type":"institution"},{"attributes":{"name":"University of Canterbury","id":983,"code":"Canterbury","region":6},"id":983,"type":"institution"},{"attributes":{"name":"Stockholm University","id":9222,"code":"Stockholm","region":9},"id":9222,"type":"institution"},{"attributes":{"name":"University of Calabar","id":5348,"code":"Calabar","region":5},"id":5348,"type":"institution"},{"attributes":{"name":"Colgate University","id":4469,"code":"Colgate","region":7},"id":4469,"type":"institution"},{"attributes":{"name":"China Agricultural University (CAU)","id":5141,"code":"China Agricultural","region":1},"id":5141,"type":"institution"},{"attributes":{"name":"Moscow State University of International Relations (MGIMO)","id":8547,"code":"MGIMO","region":9},"id":8547,"type":"institution"},{"attributes":{"name":"York University","id":8568,"code":"York","region":7},"id":8568,"type":"institution"},{"attributes":{"name":"Morehouse College","id":7554,"code":"Morehouse","region":7},"id":7554,"type":"institution"},{"attributes":{"name":"National Law University, Delhi","id":184,"code":"NLU Delhi","region":4},"id":184,"type":"institution"},{"attributes":{"name":"Clemson University","id":5937,"code":"Clemson","region":7},"id":5937,"type":"institution"},{"attributes":{"name":"Institut Teknologi Bandung","id":4630,"code":"IT Bundang","region":2},"id":4630,"type":"institution"},{"attributes":{"name":"Indian Institute of Technology Guwahati (IIT Guwahati)","id":8086,"code":"IIT Guwahati","region":4},"id":8086,"type":"institution"},{"attributes":{"name":"University of Athens","id":4075,"code":"Athens","region":9},"id":4075,"type":"institution"},{"attributes":{"name":"University of Bath","id":3688,"code":"Bath","region":10},"id":3688,"type":"institution"},{"attributes":{"name":"Universiti Malaysia Terengganu","id":7901,"code":"Terengganu","region":2},"id":7901,"type":"institution"},{"attributes":{"name":"Makerere University","id":2817,"code":"Makerere","region":5},"id":2817,"type":"institution"},{"attributes":{"name":"Linkopings Universitet","id":4852,"code":"Linkopings","region":9},"id":4852,"type":"institution"},{"attributes":{"name":"Northern Caribbean University","id":8769,"code":"Northern Carribean","region":8},"id":8769,"type":"institution"},{"attributes":{"name":"Universitas Brawijaya","id":6757,"code":"Brawijaya","region":2},"id":6757,"type":"institution"},{"attributes":{"name":"University of Calabar","id":8983,"code":"Calabar","region":5},"id":8983,"type":"institution"}]
    }
  })


  // Dummy data for mocking the json response
  this.get('/regions/', function() {
    return {
      data: [
        {
          type: "regions",
          id: 1,
          attributes: {
            name: "North Asia",
          },
        },{
          type: "regions",
          id: 2,
          attributes: {
            name: "South East Asia",
          },
        },{
          type: "regions",
          id: 3,
          attributes: {
            name: "Middle East",
          },
        },{
          type: "regions",
          id: 4,
          attributes: {
            name: "Sub Sub-Continent",
          },
        },{
          type: "regions",
          id: 5,
          attributes: {
            name: "Africa",
          },
        },{
          type: "regions",
          id: 6,
          attributes: {
            name: "ANZ",
          },
        },{
          type: "regions",
          id: 7,
          attributes: {
            name: "North America",
          },
        },{
          type: "regions",
          id: 8,
          attributes: {
            name: "Latin America",
          },
        },{
          type: "regions",
          id: 9,
          attributes: {
            name: "Europe",
          },
        },{
          type: "regions",
          id: 10,
          attributes: {
            name: "IONA",
          },
        }
      ]
    }
  });

  // Dummy data for mocking the json response
  this.get('/panels/1', function() {
    return {
      data: {
        type: "panels",
        id: 1,
        relationships: {
          chair: { "data": { "type": "adjudicator", "id": "1" } },
        }
      }
    }
  });

  // Dummy data for mocking the json response
  this.get('/panels/2', function() {
    return {
      data: {
        type: "panels",
        id: 2,
        relationships: {
          chair: { "data": { "type": "adjudicator", "id": "2" } },
          panellists: {
            "data": [
              { "type": "adjudicators", "id": "4" },
            ]
          },
        }
      }
    }
  });

  // Dummy data for mocking the json response
  this.get('/panels/3', function() {
    return {
      data: {
        type: "panels",
        id: 3,
        relationships: {
          trainees: {
            "data": [
              { "type": "adjudicators", "id": "3" }
            ]
          },
        }
      }
    }
  });

  // Dummy data for mocking the json response
  this.get('/adjudicatorsold', function() {
    return {
      data: [
        {
          type: "adjudicators",
          id: 1,
          attributes: {
            name: "Philip Belesky",
            rating: 2.0,
            gender: 2,
          },
          relationships: {
            "institutions": {
              "data": [ { "type": "institution", "id": "2" }, { "type": "institution", "id": "1" } ]
            },
            "strikedTeams": {
              "data": [ { "type": "team", "id": "5" }, { "type": "team", "id": "4" } ]
            },
          }
        },
        {
          type: "adjudicators",
          id: 2,
          attributes: {
            name: "Chuan-Zheng Lee",
            rating: 6.0,
            gender: 0,
          },
          relationships: {
            "institutions": {
              "data": [ { "type": "institution", "id": "5" } ]
            }
          }
        },
        {
          type: "adjudicators",
          id: 3,
          attributes: {
            name: "Chris Bisset",
            rating: 7.0,
            gender: 0,
          },
          relationships: {
            "institutions": {
              "data": [
                { "type": "institution", "id": "8" },
              ]
            }
          }
        },
        {
          type: "adjudicators",
          id: 4,
          attributes: {
            name: "Other Old Hack",
            rating: 1.0,
            gender: 2,
          },
          relationships: {
            "institutions": {
              "data": [
                { "type": "institution", "id": "8" },
              ]
            }
          }
        },
        {
          type: "adjudicators",
          id: 5,
          attributes: {
            name: "Other 2",
            rating: 9.0,
            gender: 0,
          },
          relationships: {
            "institutions": {
              "data": [
                { "type": "institution", "id": "8" },
              ]
            }
          }
        },
        {
          type: "adjudicators",
          id: 6,
          attributes: {
            name: "Really crap adj",
            rating: 1.0,
            gender: 0,
          },
          relationships: {
            "institutions": {
              "data": [
                { "type": "institution", "id": "6" },
              ]
            }
          }
        }
      ]
    }
  });


  // Dummy data for mocking the json response
  this.get('/adjudicators', function() {
    return {
      data: [{
        "attributes":{
          "name":"Valda Kuehner",
          "gender":2,
          "id":28192,
          "ranking":7,
          "language":2,
          "regions":[9]
        },
        "id":28192,
        "type":"adjudicator",
        "relationships":{
          "institution":{"data":{"id":2345,"type":"institution"}}}
        },
        {"attributes":{"name":"Josef Deming","gender":1,"id":86534,"ranking":1,"language":1,"regions":[9,5]},"id":86534,"type":"adjudicator","relationships":{"institution":{"data":{"id":9222,"type":"institution"}}}},{"attributes":{"name":"Sindy Priolo","gender":2,"id":53692,"ranking":5,"language":1,"regions":[1]},"id":53692,"type":"adjudicator","relationships":{"institution":{"data":{"id":2502,"type":"institution"}}}},{"attributes":{"name":"Yanira Cudjoe","gender":2,"id":63830,"ranking":7,"language":2,"regions":[7]},"id":63830,"type":"adjudicator","relationships":{"institution":{"data":{"id":4469,"type":"institution"}}}},{"attributes":{"name":"Gisele Valenzula","gender":2,"id":15047,"ranking":1,"language":1,"regions":[7]},"id":15047,"type":"adjudicator","relationships":{"institution":{"data":{"id":8568,"type":"institution"}}}},{"attributes":{"name":"Gene Raff","gender":1,"id":34922,"ranking":3,"language":1,"regions":[4]},"id":34922,"type":"adjudicator","relationships":{"institution":{"data":{"id":5708,"type":"institution"}}}},{"attributes":{"name":"So Michell","gender":2,"id":63109,"ranking":5,"language":3,"regions":[4]},"id":63109,"type":"adjudicator","relationships":{"institution":{"data":{"id":5708,"type":"institution"}}}},{"attributes":{"name":"Ardell Wiesen","gender":2,"id":68556,"ranking":6,"language":1,"regions":[6]},"id":68556,"type":"adjudicator","relationships":{"institution":{"data":{"id":2206,"type":"institution"}}}},{"attributes":{"name":"Yi Backes","gender":2,"id":18756,"ranking":2,"language":2,"regions":[1]},"id":18756,"type":"adjudicator","relationships":{"institution":{"data":{"id":2502,"type":"institution"}}}},{"attributes":{"name":"Nickolas Hunger","gender":1,"id":9677,"ranking":6,"language":1,"regions":[2]},"id":9677,"type":"adjudicator","relationships":{"institution":{"data":{"id":4630,"type":"institution"}}}},{"attributes":{"name":"Keven Canterbury","gender":1,"id":71228,"ranking":6,"language":2,"regions":[7]},"id":71228,"type":"adjudicator","relationships":{"institution":{"data":{"id":2922,"type":"institution"}}}},{"attributes":{"name":"Keven Canterbury","gender":1,"id":26168,"ranking":5,"language":2,"regions":[6,2]},"id":26168,"type":"adjudicator","relationships":{"institution":{"data":{"id":2206,"type":"institution"}}}},{"attributes":{"name":"Josephine Thayer","gender":2,"id":43793,"ranking":8,"language":1,"regions":[7]},"id":43793,"type":"adjudicator","relationships":{"institution":{"data":{"id":2922,"type":"institution"}}}},{"attributes":{"name":"Heriberto Roesner","gender":1,"id":41075,"ranking":4,"language":2,"regions":[4]},"id":41075,"type":"adjudicator","relationships":{"institution":{"data":{"id":184,"type":"institution"}}}},{"attributes":{"name":"Sixta Mcmurtrie","gender":2,"id":39811,"ranking":6,"language":2,"regions":[7]},"id":39811,"type":"adjudicator","relationships":{"institution":{"data":{"id":5937,"type":"institution"}}}},{"attributes":{"name":"Fabian Rapozo","gender":1,"id":3465,"ranking":5,"language":3,"regions":[9]},"id":3465,"type":"adjudicator","relationships":{"institution":{"data":{"id":8547,"type":"institution"}}}},{"attributes":{"name":"Vicente Geier","gender":1,"id":14683,"ranking":6,"language":3,"regions":[5]},"id":14683,"type":"adjudicator","relationships":{"institution":{"data":{"id":615,"type":"institution"}}}},{"attributes":{"name":"Ferdinand Orourke","gender":1,"id":82692,"ranking":3,"language":2,"regions":[2]},"id":82692,"type":"adjudicator","relationships":{"institution":{"data":{"id":9456,"type":"institution"}}}},{"attributes":{"name":"Vernon Trump","gender":1,"id":59173,"ranking":8,"language":2,"regions":[2]},"id":59173,"type":"adjudicator","relationships":{"institution":{"data":{"id":9456,"type":"institution"}}}},{"attributes":{"name":"Gaynell Giffen","gender":2,"id":25433,"ranking":1,"language":2,"regions":[5]},"id":25433,"type":"adjudicator","relationships":{"institution":{"data":{"id":615,"type":"institution"}}}},{"attributes":{"name":"Salina Emond","gender":2,"id":65836,"ranking":3,"language":1,"regions":[8]},"id":65836,"type":"adjudicator","relationships":{"institution":{"data":{"id":8769,"type":"institution"}}}},{"attributes":{"name":"Junita Schoemaker","gender":2,"id":79705,"ranking":1,"language":1,"regions":[4]},"id":79705,"type":"adjudicator","relationships":{"institution":{"data":{"id":8086,"type":"institution"}}}},{"attributes":{"name":"Fausto Steinhoff","gender":1,"id":42377,"ranking":6,"language":3,"regions":[10]},"id":42377,"type":"adjudicator","relationships":{"institution":{"data":{"id":9020,"type":"institution"}}}},{"attributes":{"name":"Carlton Leatherwood","gender":1,"id":25048,"ranking":6,"language":3,"regions":[7]},"id":25048,"type":"adjudicator","relationships":{"institution":{"data":{"id":8568,"type":"institution"}}}},{"attributes":{"name":"Lino Schrom","gender":1,"id":64067,"ranking":6,"language":2,"regions":[6]},"id":64067,"type":"adjudicator","relationships":{"institution":{"data":{"id":2206,"type":"institution"}}}},{"attributes":{"name":"Hang Casto","gender":2,"id":13953,"ranking":2,"language":2,"regions":[6]},"id":13953,"type":"adjudicator","relationships":{"institution":{"data":{"id":983,"type":"institution"}}}},{"attributes":{"name":"Frida Savory","gender":2,"id":3406,"ranking":1,"language":1,"regions":[9]},"id":3406,"type":"adjudicator","relationships":{"institution":{"data":{"id":2345,"type":"institution"}}}},{"attributes":{"name":"Margot Cheyne","gender":2,"id":72983,"ranking":3,"language":2,"regions":[3]},"id":72983,"type":"adjudicator","relationships":{"institution":{"data":{"id":9416,"type":"institution"}}}},{"attributes":{"name":"Garrett Allbritton","gender":1,"id":45944,"ranking":1,"language":3,"regions":[9]},"id":45944,"type":"adjudicator","relationships":{"institution":{"data":{"id":4852,"type":"institution"}}}},{"attributes":{"name":"Josephine Thayer","gender":2,"id":92210,"ranking":6,"language":1,"regions":[2]},"id":92210,"type":"adjudicator","relationships":{"institution":{"data":{"id":7901,"type":"institution"}}}},{"attributes":{"name":"Nelida Hazlitt","gender":2,"id":62870,"ranking":4,"language":1,"regions":[5]},"id":62870,"type":"adjudicator","relationships":{"institution":{"data":{"id":2817,"type":"institution"}}}},{"attributes":{"name":"Ranee Ruge","gender":2,"id":2113,"ranking":5,"language":2,"regions":[4]},"id":2113,"type":"adjudicator","relationships":{"institution":{"data":{"id":184,"type":"institution"}}}},{"attributes":{"name":"Lemuel Sugar","gender":1,"id":54976,"ranking":7,"language":3,"regions":[6]},"id":54976,"type":"adjudicator","relationships":{"institution":{"data":{"id":2206,"type":"institution"}}}},{"attributes":{"name":"Hang Casto","gender":2,"id":79534,"ranking":4,"language":3,"regions":[3]},"id":79534,"type":"adjudicator","relationships":{"institution":{"data":{"id":9416,"type":"institution"}}}},{"attributes":{"name":"Neda Mckechnie","gender":2,"id":22851,"ranking":4,"language":2,"regions":[7]},"id":22851,"type":"adjudicator","relationships":{"institution":{"data":{"id":4469,"type":"institution"}}}},{"attributes":{"name":"Louis Scheider","gender":1,"id":1199,"ranking":2,"language":3,"regions":[2]},"id":1199,"type":"adjudicator","relationships":{"institution":{"data":{"id":7901,"type":"institution"}}}},{"attributes":{"name":"Ben Porterfield","gender":1,"id":32813,"ranking":8,"language":1,"regions":[1]},"id":32813,"type":"adjudicator","relationships":{"institution":{"data":{"id":2030,"type":"institution"}}}},{"attributes":{"name":"Reid Abrahamson","gender":1,"id":42335,"ranking":5,"language":1,"regions":[5]},"id":42335,"type":"adjudicator","relationships":{"institution":{"data":{"id":8983,"type":"institution"}}}},{"attributes":{"name":"Valda Kuehner","gender":2,"id":27222,"ranking":7,"language":2,"regions":[9,5]},"id":27222,"type":"adjudicator","relationships":{"institution":{"data":{"id":8547,"type":"institution"}}}},{"attributes":{"name":"Carlos Olmsted","gender":1,"id":94604,"ranking":6,"language":3,"regions":[5]},"id":94604,"type":"adjudicator","relationships":{"institution":{"data":{"id":5375,"type":"institution"}}}},{"attributes":{"name":"Zelma Brush","gender":2,"id":30190,"ranking":8,"language":1,"regions":[7]},"id":30190,"type":"adjudicator","relationships":{"institution":{"data":{"id":5937,"type":"institution"}}}},{"attributes":{"name":"Alfonzo Glance","gender":1,"id":40101,"ranking":4,"language":2,"regions":[9]},"id":40101,"type":"adjudicator","relationships":{"institution":{"data":{"id":4075,"type":"institution"}}}},{"attributes":{"name":"Shaniqua Warkentin","gender":2,"id":32164,"ranking":6,"language":2,"regions":[1]},"id":32164,"type":"adjudicator","relationships":{"institution":{"data":{"id":5141,"type":"institution"}}}},{"attributes":{"name":"Lucien Herndon","gender":1,"id":69093,"ranking":1,"language":3,"regions":[10]},"id":69093,"type":"adjudicator","relationships":{"institution":{"data":{"id":9020,"type":"institution"}}}},{"attributes":{"name":"Cleo Armistead","gender":1,"id":68930,"ranking":7,"language":2,"regions":[5]},"id":68930,"type":"adjudicator","relationships":{"institution":{"data":{"id":33,"type":"institution"}}}},{"attributes":{"name":"Gisele Valenzula","gender":2,"id":58621,"ranking":3,"language":3,"regions":[7]},"id":58621,"type":"adjudicator","relationships":{"institution":{"data":{"id":8106,"type":"institution"}}}},{"attributes":{"name":"Raymundo Mayoral","gender":1,"id":96103,"ranking":8,"language":3,"regions":[1]},"id":96103,"type":"adjudicator","relationships":{"institution":{"data":{"id":2030,"type":"institution"}}}},{"attributes":{"name":"Theola Vince","gender":2,"id":16460,"ranking":7,"language":2,"regions":[5]},"id":16460,"type":"adjudicator","relationships":{"institution":{"data":{"id":615,"type":"institution"}}}},{"attributes":{"name":"Beau Lacaze","gender":1,"id":34515,"ranking":6,"language":1,"regions":[2]},"id":34515,"type":"adjudicator","relationships":{"institution":{"data":{"id":9456,"type":"institution"}}}},{"attributes":{"name":"Louis Scheider","gender":1,"id":99032,"ranking":7,"language":2,"regions":[6]},"id":99032,"type":"adjudicator","relationships":{"institution":{"data":{"id":9624,"type":"institution"}}}},{"attributes":{"name":"Retta Austria","gender":2,"id":80536,"ranking":3,"language":2,"regions":[5,5]},"id":80536,"type":"adjudicator","relationships":{"institution":{"data":{"id":3634,"type":"institution"}}}},{"attributes":{"name":"Pamelia Nies","gender":2,"id":77422,"ranking":6,"language":1,"regions":[7]},"id":77422,"type":"adjudicator","relationships":{"institution":{"data":{"id":5937,"type":"institution"}}}},{"attributes":{"name":"Cleo Armistead","gender":1,"id":2169,"ranking":3,"language":1,"regions":[5,4]},"id":2169,"type":"adjudicator","relationships":{"institution":{"data":{"id":33,"type":"institution"}}}},{"attributes":{"name":"Bridget Hanford","gender":2,"id":64833,"ranking":8,"language":1,"regions":[9]},"id":64833,"type":"adjudicator","relationships":{"institution":{"data":{"id":2345,"type":"institution"}}}},{"attributes":{"name":"Aileen Silas","gender":2,"id":76749,"ranking":7,"language":1,"regions":[9]},"id":76749,"type":"adjudicator","relationships":{"institution":{"data":{"id":4075,"type":"institution"}}}},{"attributes":{"name":"Mirian Carstarphen","gender":2,"id":32592,"ranking":7,"language":2,"regions":[7]},"id":32592,"type":"adjudicator","relationships":{"institution":{"data":{"id":4469,"type":"institution"}}}},{"attributes":{"name":"Svetlana Zick","gender":2,"id":34440,"ranking":3,"language":2,"regions":[10]},"id":34440,"type":"adjudicator","relationships":{"institution":{"data":{"id":9020,"type":"institution"}}}},{"attributes":{"name":"Vennie Schafer","gender":2,"id":80401,"ranking":2,"language":1,"regions":[5]},"id":80401,"type":"adjudicator","relationships":{"institution":{"data":{"id":2817,"type":"institution"}}}},{"attributes":{"name":"Adeline Buettner","gender":2,"id":18473,"ranking":4,"language":1,"regions":[2]},"id":18473,"type":"adjudicator","relationships":{"institution":{"data":{"id":4630,"type":"institution"}}}},{"attributes":{"name":"Irving Mattie","gender":1,"id":67942,"ranking":2,"language":1,"regions":[7]},"id":67942,"type":"adjudicator","relationships":{"institution":{"data":{"id":5937,"type":"institution"}}}}
      ]
    }
  });

  // Dummy data for mocking the json response
  this.get('/debatesold', function() {
    return {
      data: [

        {
          type: "debates",
          id: 1,
          attributes: {
            debate_id: "1",
            points: "5",
            venue: "DM 01",
          },
          relationships: {
            "og":     { "data": { "type": "team", "id": "1" } },
            "oo":     { "data": { "type": "team", "id": "2" } },
            "cg":     { "data": { "type": "team", "id": "3" } },
            "co":     { "data": { "type": "team", "id": "4" } },
            "panel":  { "data": { "type": "panel", "id": "1" } }
          }
        },
        {
          type: "debates",
          id: 2,
          attributes: {
            debate_id: "2",
            points: "1",
            venue: "RM 04",
          },
          relationships: {
            "og": { "data": { "type": "team", "id": "5" } },
            "oo": { "data": { "type": "team", "id": "6" } },
            "cg": { "data": { "type": "team", "id": "7" } },
            "co": { "data": { "type": "team", "id": "8" } },
            "panel": { "data": { "type": "panel", "id": "2" } }
          }
        },
        {
          type: "debates",
          id: 3,
          attributes: {
            debate_id: "3",
            points: "0",
            venue: "RM 99",
          },
          relationships: {
            "og": { "data": { "type": "team", "id": "9" } },
            "oo": { "data": { "type": "team", "id": "10" } },
            "cg": { "data": { "type": "team", "id": "11" } },
            "co": { "data": { "type": "team", "id": "11" } },
            "panel": { "data": { "type": "panel", "id": "3" } }
          }
        }
      ],
      "included": [
        {
            "type": "team",
            "id": "1",
            "attributes": {
              "name": "Cambridge A",
              "gender": 0,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "1" }}}
        },
        {
            "type": "team",
            "id": "2",
            "attributes": {
              "name": "Hart House A",
              "gender": 1,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "2" }}}
        },
        {
            "type": "team",
            "id": "3",
            "attributes": {
              "name": "Harvard A",
              "gender": 2,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "3" }}}
        },
        {
            "type": "team",
            "id": "4",
            "attributes": {
              "name": "BPP A",
              "gender": 0,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "4" }}}
        },{
            "type": "team",
            "id": "5",
            "attributes": {
              "name": "Cambridge B",
              "gender": 1,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "5" }}}
        },
        {
            "type": "team",
            "id": "6",
            "attributes": {
              "name": "Sydney D",
              "gender": 2,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "6" }}}
        },
        {
            "type": "team",
            "id": "7",
            "attributes": {
              "name": "Melbourne A",
              "gender": 0,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "7" }}}
        },
        {
            "type": "team",
            "id": "8",
            "attributes": {
              "name": "Oxford B",
              "gender": 1,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "8" }}}
        },{
            "type": "team",
            "id": "9",
            "attributes": {
              "name": "Durham A",
              "gender": 1,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "9" }}}
        },
        {
            "type": "team",
            "id": "10",
            "attributes": {
              "name": "IIUM A",
              "gender": 2,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "10" }}}
        },
        {
            "type": "team",
            "id": "11",
            "attributes": {
              "name": "New South Wales B",
              "gender": 0,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "1" }}}
        },
        {
            "type": "team",
            "id": "12",
            "attributes": {
              "name": "Vic Wellington A",
              "gender": 1,
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "2" }}}
        }
        ]
    }
  });


  // Dummy data for mocking the json response
  this.get('/debates', function() {
    return {
      data: [{"attributes":{"weight":3.8473598020998967,"id":73347},"id":73347,"type":"debate","relationships":{"teams":{"data":[{"id":42480,"type":"team"},{"id":51371,"type":"team"},{"id":53054,"type":"team"},{"id":8149,"type":"team"}]}}},{"attributes":{"weight":0.08237259819895426,"id":93763},"id":93763,"type":"debate","relationships":{"teams":{"data":[{"id":60314,"type":"team"},{"id":78950,"type":"team"},{"id":31258,"type":"team"},{"id":78467,"type":"team"}]}}},{"attributes":{"weight":7.5224159946601805,"id":65310},"id":65310,"type":"debate","relationships":{"teams":{"data":[{"id":56295,"type":"team"},{"id":30864,"type":"team"},{"id":59342,"type":"team"},{"id":6051,"type":"team"}]}}},{"attributes":{"weight":6.854955312255702,"id":57998},"id":57998,"type":"debate","relationships":{"teams":{"data":[{"id":88021,"type":"team"},{"id":34195,"type":"team"},{"id":49599,"type":"team"},{"id":81910,"type":"team"}]}}},{"attributes":{"weight":3.6819012775293314,"id":8570},"id":8570,"type":"debate","relationships":{"teams":{"data":[{"id":79310,"type":"team"},{"id":12687,"type":"team"},{"id":3666,"type":"team"},{"id":56287,"type":"team"}]}}},{"attributes":{"weight":4.006795210170846,"id":58861},"id":58861,"type":"debate","relationships":{"teams":{"data":[{"id":38338,"type":"team"},{"id":52352,"type":"team"},{"id":48813,"type":"team"},{"id":77488,"type":"team"}]}}},{"attributes":{"weight":5.9278018779465524,"id":97112},"id":97112,"type":"debate","relationships":{"teams":{"data":[{"id":61081,"type":"team"},{"id":69542,"type":"team"},{"id":53579,"type":"team"},{"id":77888,"type":"team"}]}}},{"attributes":{"weight":2.132485667073072,"id":13269},"id":13269,"type":"debate","relationships":{"teams":{"data":[{"id":48489,"type":"team"},{"id":62127,"type":"team"},{"id":37487,"type":"team"},{"id":47325,"type":"team"}]}}},{"attributes":{"weight":8.513080911238976,"id":48609},"id":48609,"type":"debate","relationships":{"teams":{"data":[{"id":16043,"type":"team"},{"id":78262,"type":"team"},{"id":41247,"type":"team"},{"id":34373,"type":"team"}]}}},{"attributes":{"weight":6.566583920476255,"id":56152},"id":56152,"type":"debate","relationships":{"teams":{"data":[{"id":79829,"type":"team"},{"id":40652,"type":"team"},{"id":78879,"type":"team"},{"id":94209,"type":"team"}]}}},{"attributes":{"weight":2.0179586747941713,"id":40546},"id":40546,"type":"debate","relationships":{"teams":{"data":[{"id":51589,"type":"team"},{"id":1274,"type":"team"},{"id":23948,"type":"team"},{"id":1490,"type":"team"}]}}},{"attributes":{"weight":5.289039118898577,"id":5408},"id":5408,"type":"debate","relationships":{"teams":{"data":[{"id":86240,"type":"team"},{"id":54196,"type":"team"},{"id":72266,"type":"team"},{"id":24632,"type":"team"}]}}},{"attributes":{"weight":7.149907171942624,"id":53501},"id":53501,"type":"debate","relationships":{"teams":{"data":[{"id":53205,"type":"team"},{"id":70991,"type":"team"},{"id":51212,"type":"team"},{"id":36549,"type":"team"}]}}},{"attributes":{"weight":1.5458716557836016,"id":77933},"id":77933,"type":"debate","relationships":{"teams":{"data":[{"id":62466,"type":"team"},{"id":14744,"type":"team"},{"id":38941,"type":"team"},{"id":26665,"type":"team"}]}}},{"attributes":{"weight":0.09656857527926554,"id":3254},"id":3254,"type":"debate","relationships":{"teams":{"data":[{"id":62273,"type":"team"},{"id":19724,"type":"team"},{"id":67276,"type":"team"},{"id":21791,"type":"team"}]}}},{"attributes":{"weight":5.169253967410903,"id":31245},"id":31245,"type":"debate","relationships":{"teams":{"data":[{"id":139,"type":"team"},{"id":14855,"type":"team"},{"id":92865,"type":"team"},{"id":78600,"type":"team"}]}}},{"attributes":{"weight":3.3490647734451895,"id":28252},"id":28252,"type":"debate","relationships":{"teams":{"data":[{"id":6248,"type":"team"},{"id":65808,"type":"team"},{"id":21304,"type":"team"},{"id":67287,"type":"team"}]}}},{"attributes":{"weight":6.995854132651047,"id":48920},"id":48920,"type":"debate","relationships":{"teams":{"data":[{"id":84215,"type":"team"},{"id":3220,"type":"team"},{"id":84413,"type":"team"},{"id":57543,"type":"team"}]}}},{"attributes":{"weight":3.1306456130632743,"id":95548},"id":95548,"type":"debate","relationships":{"teams":{"data":[{"id":27729,"type":"team"},{"id":23198,"type":"team"},{"id":41517,"type":"team"},{"id":11992,"type":"team"}]}}},{"attributes":{"weight":2.346788188082356,"id":62870},"id":62870,"type":"debate","relationships":{"teams":{"data":[{"id":6146,"type":"team"},{"id":24704,"type":"team"},{"id":28526,"type":"team"},{"id":84456,"type":"team"}]}}}]
    }
  });

  // Dummy data for mocking the json response
  this.get('/teams', function() {
    return {
      data: [{
        "attributes": {
          "name":"York 1","gender":1,"id":78950,"language":3,"region":7
        },
        "id":78950,
        "type":"team",
        "relationships": {
          "institution": {"data":{"id":8568,"type":"institution"}
        }
      }},
      {"attributes":{"name":"Calabar 1","gender":1,"id":51589,"language":3,"region":5},"id":51589,"type":"team","relationships":{"institution":{"data":{"id":8983,"type":"institution"}}}},{"attributes":{"name":"MGIMO 1","gender":3,"id":21791,"language":1,"region":9},"id":21791,"type":"team","relationships":{"institution":{"data":{"id":8547,"type":"institution"}}}},{"attributes":{"name":"Linkopings 1","gender":2,"id":54196,"language":3,"region":9},"id":54196,"type":"team","relationships":{"institution":{"data":{"id":4852,"type":"institution"}}}},{"attributes":{"name":"Athens 1","gender":2,"id":84215,"language":3,"region":9},"id":84215,"type":"team","relationships":{"institution":{"data":{"id":4075,"type":"institution"}}}},{"attributes":{"name":"Botswana 1","gender":2,"id":14744,"language":1,"region":5},"id":14744,"type":"team","relationships":{"institution":{"data":{"id":3634,"type":"institution"}}}},{"attributes":{"name":"Western Australia 1","gender":1,"id":139,"language":3,"region":6},"id":139,"type":"team","relationships":{"institution":{"data":{"id":2206,"type":"institution"}}}},{"attributes":{"name":"Namibia 1","gender":2,"id":11992,"language":1,"region":5},"id":11992,"type":"team","relationships":{"institution":{"data":{"id":5375,"type":"institution"}}}},{"attributes":{"name":"Sun Yat Sen 1","gender":3,"id":34373,"language":3,"region":1},"id":34373,"type":"team","relationships":{"institution":{"data":{"id":2030,"type":"institution"}}}},{"attributes":{"name":"Copenhangen 1","gender":3,"id":78262,"language":1,"region":9},"id":78262,"type":"team","relationships":{"institution":{"data":{"id":1804,"type":"institution"}}}},{"attributes":{"name":"Victoria Canada 1","gender":2,"id":14855,"language":2,"region":7},"id":14855,"type":"team","relationships":{"institution":{"data":{"id":2922,"type":"institution"}}}},{"attributes":{"name":"Victoria Canada 2","gender":2,"id":28526,"language":3,"region":7},"id":28526,"type":"team","relationships":{"institution":{"data":{"id":2922,"type":"institution"}}}},{"attributes":{"name":"Terengganu 1","gender":3,"id":30864,"language":2,"region":2},"id":30864,"type":"team","relationships":{"institution":{"data":{"id":7901,"type":"institution"}}}},{"attributes":{"name":"Clemson 1","gender":1,"id":78879,"language":2,"region":7},"id":78879,"type":"team","relationships":{"institution":{"data":{"id":5937,"type":"institution"}}}},{"attributes":{"name":"Makerere 1","gender":3,"id":62127,"language":1,"region":5},"id":62127,"type":"team","relationships":{"institution":{"data":{"id":2817,"type":"institution"}}}},{"attributes":{"name":"Stockholm 1","gender":3,"id":21304,"language":3,"region":9},"id":21304,"type":"team","relationships":{"institution":{"data":{"id":9222,"type":"institution"}}}},{"attributes":{"name":"IIT Guwahati 1","gender":2,"id":1490,"language":1,"region":4},"id":1490,"type":"team","relationships":{"institution":{"data":{"id":8086,"type":"institution"}}}},{"attributes":{"name":"Linkopings 2","gender":3,"id":52352,"language":3,"region":9},"id":52352,"type":"team","relationships":{"institution":{"data":{"id":4852,"type":"institution"}}}},{"attributes":{"name":"Terengganu 2","gender":3,"id":41247,"language":3,"region":2},"id":41247,"type":"team","relationships":{"institution":{"data":{"id":7901,"type":"institution"}}}},{"attributes":{"name":"Northern Carribean 1","gender":2,"id":3666,"language":2,"region":8},"id":3666,"type":"team","relationships":{"institution":{"data":{"id":8769,"type":"institution"}}}},{"attributes":{"name":"Botswana 2","gender":1,"id":53054,"language":3,"region":5},"id":53054,"type":"team","relationships":{"institution":{"data":{"id":3634,"type":"institution"}}}},{"attributes":{"name":"Stockholm 2","gender":3,"id":36549,"language":1,"region":9},"id":36549,"type":"team","relationships":{"institution":{"data":{"id":9222,"type":"institution"}}}},{"attributes":{"name":"York 2","gender":3,"id":77888,"language":1,"region":7},"id":77888,"type":"team","relationships":{"institution":{"data":{"id":8568,"type":"institution"}}}},{"attributes":{"name":"Linkopings 3","gender":2,"id":51212,"language":1,"region":9},"id":51212,"type":"team","relationships":{"institution":{"data":{"id":4852,"type":"institution"}}}},{"attributes":{"name":"Northern Carribean 2","gender":1,"id":56295,"language":3,"region":8},"id":56295,"type":"team","relationships":{"institution":{"data":{"id":8769,"type":"institution"}}}},{"attributes":{"name":"Bath 1","gender":3,"id":53205,"language":1,"region":10},"id":53205,"type":"team","relationships":{"institution":{"data":{"id":3688,"type":"institution"}}}},{"attributes":{"name":"IIU Malaysia 1","gender":1,"id":26665,"language":3,"region":2},"id":26665,"type":"team","relationships":{"institution":{"data":{"id":5710,"type":"institution"}}}},{"attributes":{"name":"Makerere 2","gender":2,"id":62466,"language":2,"region":5},"id":62466,"type":"team","relationships":{"institution":{"data":{"id":2817,"type":"institution"}}}},{"attributes":{"name":"Zimbabwe 1","gender":1,"id":84456,"language":1,"region":5},"id":84456,"type":"team","relationships":{"institution":{"data":{"id":33,"type":"institution"}}}},{"attributes":{"name":"Linkopings 4","gender":2,"id":24704,"language":2,"region":9},"id":24704,"type":"team","relationships":{"institution":{"data":{"id":4852,"type":"institution"}}}},{"attributes":{"name":"Colgate 1","gender":2,"id":1274,"language":1,"region":7},"id":1274,"type":"team","relationships":{"institution":{"data":{"id":4469,"type":"institution"}}}},{"attributes":{"name":"Pretoria 1","gender":2,"id":19724,"language":1,"region":5},"id":19724,"type":"team","relationships":{"institution":{"data":{"id":615,"type":"institution"}}}},{"attributes":{"name":"Botswana 3","gender":2,"id":23948,"language":3,"region":5},"id":23948,"type":"team","relationships":{"institution":{"data":{"id":3634,"type":"institution"}}}},{"attributes":{"name":"Koc 1","gender":3,"id":78600,"language":1,"region":3},"id":78600,"type":"team","relationships":{"institution":{"data":{"id":9416,"type":"institution"}}}},{"attributes":{"name":"UT Sydney 1","gender":1,"id":53579,"language":1,"region":6},"id":53579,"type":"team","relationships":{"institution":{"data":{"id":9624,"type":"institution"}}}},{"attributes":{"name":"IT Bundang 1","gender":1,"id":6051,"language":1,"region":2},"id":6051,"type":"team","relationships":{"institution":{"data":{"id":4630,"type":"institution"}}}},{"attributes":{"name":"Stockholm 3","gender":1,"id":69542,"language":1,"region":9},"id":69542,"type":"team","relationships":{"institution":{"data":{"id":9222,"type":"institution"}}}},{"attributes":{"name":"Mostar 1","gender":1,"id":42480,"language":1,"region":9},"id":42480,"type":"team","relationships":{"institution":{"data":{"id":2345,"type":"institution"}}}},{"attributes":{"name":"Makerere 3","gender":3,"id":72266,"language":2,"region":5},"id":72266,"type":"team","relationships":{"institution":{"data":{"id":2817,"type":"institution"}}}},{"attributes":{"name":"Natl Taiwan 1","gender":1,"id":92865,"language":3,"region":1},"id":92865,"type":"team","relationships":{"institution":{"data":{"id":2502,"type":"institution"}}}},{"attributes":{"name":"Brawijaya 1","gender":3,"id":23198,"language":3,"region":2},"id":23198,"type":"team","relationships":{"institution":{"data":{"id":6757,"type":"institution"}}}},{"attributes":{"name":"Victoria Canada 3","gender":1,"id":62273,"language":1,"region":7},"id":62273,"type":"team","relationships":{"institution":{"data":{"id":2922,"type":"institution"}}}},{"attributes":{"name":"Calabar 1","gender":1,"id":6248,"language":3,"region":5},"id":6248,"type":"team","relationships":{"institution":{"data":{"id":5348,"type":"institution"}}}},{"attributes":{"name":"Victoria Canada 4","gender":3,"id":67287,"language":2,"region":7},"id":67287,"type":"team","relationships":{"institution":{"data":{"id":2922,"type":"institution"}}}},{"attributes":{"name":"Calabar 2","gender":3,"id":12687,"language":1,"region":5},"id":12687,"type":"team","relationships":{"institution":{"data":{"id":8983,"type":"institution"}}}},{"attributes":{"name":"Canterbury 1","gender":2,"id":78467,"language":3,"region":6},"id":78467,"type":"team","relationships":{"institution":{"data":{"id":983,"type":"institution"}}}},{"attributes":{"name":"Calabar 2","gender":2,"id":6146,"language":3,"region":5},"id":6146,"type":"team","relationships":{"institution":{"data":{"id":5348,"type":"institution"}}}},{"attributes":{"name":"Bath 2","gender":3,"id":86240,"language":3,"region":10},"id":86240,"type":"team","relationships":{"institution":{"data":{"id":3688,"type":"institution"}}}},{"attributes":{"name":"Calabar 3","gender":2,"id":84413,"language":1,"region":5},"id":84413,"type":"team","relationships":{"institution":{"data":{"id":5348,"type":"institution"}}}},{"attributes":{"name":"Botswana 4","gender":3,"id":61081,"language":3,"region":5},"id":61081,"type":"team","relationships":{"institution":{"data":{"id":3634,"type":"institution"}}}},{"attributes":{"name":"Makerere 4","gender":3,"id":77488,"language":1,"region":5},"id":77488,"type":"team","relationships":{"institution":{"data":{"id":2817,"type":"institution"}}}},{"attributes":{"name":"Koc 2","gender":1,"id":37487,"language":3,"region":3},"id":37487,"type":"team","relationships":{"institution":{"data":{"id":9416,"type":"institution"}}}},{"attributes":{"name":"Brawijaya 2","gender":1,"id":3220,"language":2,"region":2},"id":3220,"type":"team","relationships":{"institution":{"data":{"id":6757,"type":"institution"}}}},{"attributes":{"name":"Padjadjaran 1","gender":2,"id":31258,"language":3,"region":2},"id":31258,"type":"team","relationships":{"institution":{"data":{"id":9456,"type":"institution"}}}},{"attributes":{"name":"Western Australia 2","gender":3,"id":51371,"language":1,"region":6},"id":51371,"type":"team","relationships":{"institution":{"data":{"id":2206,"type":"institution"}}}},{"attributes":{"name":"Morehouse 1","gender":3,"id":65808,"language":1,"region":7},"id":65808,"type":"team","relationships":{"institution":{"data":{"id":7554,"type":"institution"}}}},{"attributes":{"name":"UT Sydney 2","gender":3,"id":79829,"language":2,"region":6},"id":79829,"type":"team","relationships":{"institution":{"data":{"id":9624,"type":"institution"}}}},{"attributes":{"name":"Western Australia 3","gender":2,"id":40652,"language":1,"region":6},"id":40652,"type":"team","relationships":{"institution":{"data":{"id":2206,"type":"institution"}}}},{"attributes":{"name":"York 1","gender":3,"id":56287,"language":2,"region":7},"id":56287,"type":"team","relationships":{"institution":{"data":{"id":8106,"type":"institution"}}}},{"attributes":{"name":"Namibia 2","gender":1,"id":8149,"language":3,"region":5},"id":8149,"type":"team","relationships":{"institution":{"data":{"id":5375,"type":"institution"}}}},{"attributes":{"name":"NLU Delhi 1","gender":3,"id":81910,"language":2,"region":4},"id":81910,"type":"team","relationships":{"institution":{"data":{"id":184,"type":"institution"}}}},{"attributes":{"name":"UT Sydney 3","gender":2,"id":60314,"language":1,"region":6},"id":60314,"type":"team","relationships":{"institution":{"data":{"id":9624,"type":"institution"}}}},{"attributes":{"name":"Sun Yat Sen 2","gender":2,"id":67276,"language":3,"region":1},"id":67276,"type":"team","relationships":{"institution":{"data":{"id":2030,"type":"institution"}}}},{"attributes":{"name":"Copenhangen 2","gender":3,"id":49599,"language":2,"region":9},"id":49599,"type":"team","relationships":{"institution":{"data":{"id":1804,"type":"institution"}}}},{"attributes":{"name":"Botswana 5","gender":3,"id":24632,"language":2,"region":5},"id":24632,"type":"team","relationships":{"institution":{"data":{"id":3634,"type":"institution"}}}},{"attributes":{"name":"Chittagong 1","gender":3,"id":27729,"language":1,"region":4},"id":27729,"type":"team","relationships":{"institution":{"data":{"id":5708,"type":"institution"}}}},{"attributes":{"name":"IIT Guwahati 2","gender":1,"id":38941,"language":2,"region":4},"id":38941,"type":"team","relationships":{"institution":{"data":{"id":8086,"type":"institution"}}}},{"attributes":{"name":"York 3","gender":2,"id":59342,"language":2,"region":7},"id":59342,"type":"team","relationships":{"institution":{"data":{"id":8568,"type":"institution"}}}},{"attributes":{"name":"IIT Guwahati 3","gender":2,"id":47325,"language":1,"region":4},"id":47325,"type":"team","relationships":{"institution":{"data":{"id":8086,"type":"institution"}}}},{"attributes":{"name":"IT Bundang 2","gender":1,"id":48813,"language":1,"region":2},"id":48813,"type":"team","relationships":{"institution":{"data":{"id":4630,"type":"institution"}}}},{"attributes":{"name":"Terengganu 1","gender":2,"id":16043,"language":2,"region":2},"id":16043,"type":"team","relationships":{"institution":{"data":{"id":6816,"type":"institution"}}}},{"attributes":{"name":"Athens 2","gender":1,"id":48489,"language":1,"region":9},"id":48489,"type":"team","relationships":{"institution":{"data":{"id":4075,"type":"institution"}}}},{"attributes":{"name":"IT Bundang 3","gender":1,"id":34195,"language":3,"region":2},"id":34195,"type":"team","relationships":{"institution":{"data":{"id":4630,"type":"institution"}}}},{"attributes":{"name":"Brawijaya 3","gender":3,"id":88021,"language":3,"region":2},"id":88021,"type":"team","relationships":{"institution":{"data":{"id":6757,"type":"institution"}}}},{"attributes":{"name":"Zimbabwe 2","gender":2,"id":38338,"language":3,"region":5},"id":38338,"type":"team","relationships":{"institution":{"data":{"id":33,"type":"institution"}}}},{"attributes":{"name":"Copenhangen 3","gender":2,"id":79310,"language":1,"region":9},"id":79310,"type":"team","relationships":{"institution":{"data":{"id":1804,"type":"institution"}}}},{"attributes":{"name":"Calabar 4","gender":1,"id":41517,"language":3,"region":5},"id":41517,"type":"team","relationships":{"institution":{"data":{"id":5348,"type":"institution"}}}},{"attributes":{"name":"Koc 3","gender":3,"id":57543,"language":2,"region":3},"id":57543,"type":"team","relationships":{"institution":{"data":{"id":9416,"type":"institution"}}}},{"attributes":{"name":"Northern Carribean 3","gender":3,"id":70991,"language":3,"region":8},"id":70991,"type":"team","relationships":{"institution":{"data":{"id":8769,"type":"institution"}}}},{"attributes":{"name":"Northern Carribean 4","gender":3,"id":94209,"language":2,"region":8},"id":94209,"type":"team","relationships":{"institution":{"data":{"id":8769,"type":"institution"}}}}]
    }
  });

  // These comments are here to help you get started. Feel free to delete them.

  /*
    Config (with defaults).

    Note: these only affect routes defined *after* them!
  */
  // this.urlPrefix = '';    // make this `http://localhost:8080`, for example, if your API is on a different server
  // this.namespace = '';    // make this `api`, for example, if your API is namespaced
  // this.timing = 400;      // delay for each request, automatically set to 0 during testing

  /*
    Route shorthand cheatsheet
  */
  /*
    GET shorthands

    // Collections
    this.get('/contacts');
    this.get('/contacts', 'users');
    this.get('/contacts', ['contacts', 'addresses']);

    // Single objects
    this.get('/contacts/:id');
    this.get('/contacts/:id', 'user');
    this.get('/contacts/:id', ['contact', 'addresses']);
  */

  /*
    POST shorthands

    this.post('/contacts');
    this.post('/contacts', 'user'); // specify the type of resource to be created
  */

  /*
    PUT shorthands

    this.put('/contacts/:id');
    this.put('/contacts/:id', 'user'); // specify the type of resource to be updated
  */

  /*
    DELETE shorthands

    this.del('/contacts/:id');
    this.del('/contacts/:id', 'user'); // specify the type of resource to be deleted

    // Single object + related resources. Make sure parent resource is first.
    this.del('/contacts/:id', ['contact', 'addresses']);
  */

  /*
    Function fallback. Manipulate data in the db via

      - db.{collection}
      - db.{collection}.find(id)
      - db.{collection}.where(query)
      - db.{collection}.update(target, attrs)
      - db.{collection}.remove(target)

    // Example: return a single object with related models
    this.get('/contacts/:id', function(db, request) {
      var contactId = +request.params.id;

      return {
        contact: db.contacts.find(contactId),
        addresses: db.addresses.where({contact_id: contactId})
      };
    });

  */
}

/*
You can optionally export a config that is only loaded during tests
export function testConfig() {

}
*/
