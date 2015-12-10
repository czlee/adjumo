export default function() {

  // Dummy data for mocking the json response
  this.get('/institutions/', function() {
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
              { "type": "adjudicators", "id": "3" },
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
              { "type": "adjudicators", "id": "5" }
            ]
          },
        }
      }
    }
  });

  // Dummy data for mocking the json response
  this.get('/adjudicators', function() {
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
              "data": [ { "type": "team", "id": "1" } ]
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
            name: "Other Old Hack 2",
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
        }
      ]
    }
  });

  // Dummy data for mocking the json response
  this.get('/debates', function() {
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
              "region": "United Kingdom"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "1" }}}
        },
        {
            "type": "team",
            "id": "2",
            "attributes": {
              "name": "Hart House A",
              "gender": 1,
              "region": "North America"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "2" }}}
        },
        {
            "type": "team",
            "id": "3",
            "attributes": {
              "name": "Harvard A",
              "gender": 2,
              "region": "North America"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "3" }}}
        },
        {
            "type": "team",
            "id": "4",
            "attributes": {
              "name": "BPP A",
              "gender": 0,
              "region": "Europe"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "4" }}}
        },{
            "type": "team",
            "id": "5",
            "attributes": {
              "name": "Cambridge B",
              "gender": 1,
              "region": "IONA"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "5" }}}
        },
        {
            "type": "team",
            "id": "6",
            "attributes": {
              "name": "Sydney D",
              "gender": 2,
              "region": "Oceania"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "6" }}}
        },
        {
            "type": "team",
            "id": "7",
            "attributes": {
              "name": "Melbourne A",
              "gender": 0,
              "region": "South East Asia"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "7" }}}
        },
        {
            "type": "team",
            "id": "8",
            "attributes": {
              "name": "Oxford B",
              "gender": 1,
              "region": "Middle East"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "8" }}}
        },{
            "type": "team",
            "id": "9",
            "attributes": {
              "name": "Durham A",
              "gender": 1,
              "region": "Sub-Continent"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "9" }}}
        },
        {
            "type": "team",
            "id": "10",
            "attributes": {
              "name": "IIUM A",
              "gender": 2,
              "region": "Africa"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "10" }}}
        },
        {
            "type": "team",
            "id": "11",
            "attributes": {
              "name": "New South Wales B",
              "gender": 0,
              "region": "South East Asia"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "1" }}}
        },
        {
            "type": "team",
            "id": "12",
            "attributes": {
              "name": "Vic Wellington A",
              "gender": 1,
              "region": "North Asia"
            },
            relationships: { "institution": { "data": { "type": "institution", "id": "2" }}}
        }
        ]
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
