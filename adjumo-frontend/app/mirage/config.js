export default function() {

  // Dummy data for mocking the json response
  this.get('/panels/1', function() {
    return {
      data: {
        type: "panels",
        id: 1,
        "relationships": {
          "chair": { "data": { "type": "adjudicator", "id": "1" } },
          "panellists": [],
          "trainees": [],
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
        "relationships": {
          "chair": { "data": { "type": "adjudicator", "id": "2" } },
          "panellists": [],
          "trainees": [],
        }
      }
    }
  });

  // Dummy data for mocking the json response
  this.get('/institutions/1', function() {
    return {
      data: {
        type: "institutions",
        id: 1,
        attributes: {
          name: "VUW",
        }
      }
    }
  });
  // Dummy data for mocking the json response
  this.get('/institutions/2', function() {
    return {
      data: {
        type: "institutions",
        id: 2,
        attributes: {
          name: "Auck",
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
            name: "Philip",
            rating: 5.0,
          },
          relationships: {
            "institution": { "data": { "type": "institution", "id": "1" } }
          }
        },
        {
          type: "adjudicators",
          id: 2,
          attributes: {
            name: "CZ",
            rating: 5.0,
          },
          relationships: {
            "institution": { "data": { "type": "institution", "id": "2" } }
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
          "relationships": {
            "og": { "data": { "type": "team", "id": "1" } },
            "oo": { "data": { "type": "team", "id": "2" } },
            "cg": { "data": { "type": "team", "id": "3" } },
            "co": { "data": { "type": "team", "id": "4" } },
            "panel": { "data": { "type": "panel", "id": "1" } }
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
          "relationships": {
            "og": { "data": { "type": "team", "id": "5" } },
            "oo": { "data": { "type": "team", "id": "6" } },
            "cg": { "data": { "type": "team", "id": "7" } },
            "co": { "data": { "type": "team", "id": "8" } },
            "panel": { "data": { "type": "panel", "id": "2" } }
          }
        }
      ],

      "included": [
        {
            "type": "team",
            "id": "1",
            "attributes": {
              "name": "Sefa!"
            }
        },
        {
            "type": "team",
            "id": "2",
            "attributes": {
              "name": "Sefa2!"
            }
        },
        {
            "type": "team",
            "id": "3",
            "attributes": {
              "name": "Sefa3!"
            }
        },
        {
            "type": "team",
            "id": "4",
            "attributes": {
              "name": "Sefa4!"
            }
        },{
            "type": "team",
            "id": "5",
            "attributes": {
              "name": "FFSefa!"
            }
        },
        {
            "type": "team",
            "id": "6",
            "attributes": {
              "name": "TRSefa2!"
            }
        },
        {
            "type": "team",
            "id": "7",
            "attributes": {
              "name": "DFSefa3!"
            }
        },
        {
            "type": "team",
            "id": "8",
            "attributes": {
              "name": "SSSefa4!"
            }
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
