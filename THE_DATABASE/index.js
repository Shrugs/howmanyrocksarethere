'use strict';

require('dotenv').config({silent: true});

var express = require('express')
var app = express()
var pmongo = require('promised-mongo')
var ObjectID = pmongo.ObjectId
var crypto = require('crypto')
var images = require('./images')

var db = pmongo(
  process.env.MONGODB_URI || 'mongodb://localhost:27017/howmanyrocks',
  { authMechanism: 'ScramSHA1' }
)
var counters = db.collection('counters')
var rocks = db.collection('rocks')
var notrocks = db.collection('notrocks')
var users = db.collection('users')

rocks.createIndex({ location: '2dsphere' })

/**
 * Express Middleware
 */
app.use(require('body-parser').json())
app.set('secret', process.env.APP_SECRET || 'lolsecrets')
app.use(require('morgan')('dev'));

/**
 * Authorization Middleware
 */
app.use(function (req, res, next) {
  if (req.headers.authorization) {
    // look up user by token and add
    users.findOne({
      token: req.headers.authorization.split('token=')[1]
    })
    .then(function(user) {
      req.user = user
      next();
    })
    .catch(function(err) {
      console.log(err)
      next();
    })
  } else {
    next();
  }
});

/**
 * INIT
 */

// upsert the rock autoincrementing counter
counters.findOne({ _id: 'rock_id' })
  .then(function(ret) {
    if (!ret) {
      counters.insert({
        _id: 'rock_id',
        seq: 0
      })
    }
  })

counters.findOne({ _id: 'notrock_id' })
  .then(function(ret) {
    if (!ret) {
      counters.insert({
        _id: 'notrock_id',
        seq: 130000000
      })
    }
  })

users.createIndex( { username: 1 }, { unique: true } )

/**
 * Utilities
 */
function getNextId(name) {
  return counters.findAndModify({
      query: { _id: name + '_id' },
      update: { $inc: { seq: 1 } },
      new: true
    })
    .then(function(ret) {
      return ret.value.seq
    })
}

function onError(res) {
  return function(err) {
    console.log(err)

    res.status(500).json({
      err: err.message
    })

    throw err
  }
}

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomPicture() {
  return images[getRandomInt(0, images.length)]
}

function formatUsername(username) {
  return (username || '').toLowerCase().replace(/\s+/g, '')
}

function isAsciiString(str) {
  return /^[\x00-\x7F]*$/.test(str);
}

function isValidUsername(username) {
  return isAsciiString(username) &&
    formatUsername(username) === username &&
    username.length > 3
}

/**
 * Routes
 */

app.get('/remap-ids', function(req, res) {
  rocks
    .find({})
    .sort({ created_at: 1 })
    .toArray()
    .then((results) => {
      var ps = []
      results.forEach((rock, i) => {
        console.log(`${rock.id} => ${i+1}`)
        ps.push(
          rocks.update({ _id: ObjectID(rock._id) }, {
            $set: { id: i+1 }
          })
        )
      })
      return Promise.all(ps)
    })
    .then((results) => {
      res.json(results)
    })
    .catch(onError(res))
})
app.get('/user/:id', function(req, res) {
  users.findOne({
    _id: ObjectID(req.params.id)
  })
  .then(function(user) {
    res.json(user)
  })
  .catch(onError(res))
})

app.post('/users', function(req, res) {
  users.insert({
    username: formatUsername(req.body.username),
    token: crypto.randomBytes(64).toString('hex'),
    image: randomPicture()
  })
  .then(function(user) {
    res.json(user);
  })
})

app.get('/total-rocks', function(req, res) {
  rocks.count()
    .then((ret) => {
      res.json({
        count: ret
      })
    })
})

app.get('/valid-username', function(req, res) {
  var username = req.query.username

  if (!isValidUsername(username)) {
    res.json({
      valid: false
    })
    return
  }

  users
    .findOne({ username: username })
    .then((ret) => {
      res.json({
        valid: !ret
      })
    })
})

function getCollectionHandler(collection) {
  return (req, res) => {
    var lastCreatedAt = req.query.lastCreatedAt
    lastCreatedAt = lastCreatedAt ?
                      (new Date(lastCreatedAt)) :
                      (new Date())

    collection
      .find({ created_at: { $lt: lastCreatedAt } })
      .limit(5)
      .sort({ created_at: -1 })
      .toArray()
      .then(function(results) {
        // for each rock, load the user
        return Promise
          .all(results.map(function(result) {
            if (!result.owner_id) {
              return Promise.resolve(result)
            }
            // fuck performance lol
            return users.findOne({
              _id: ObjectID(result.owner_id)
            })
            .then(function(user) {
              return Object.assign(result, {
                owner: user
              })
            })
          }))
      })
      .then(function(results) {
        res.json(results)
      })
      .catch((e) => {
        res.sendStatus(500);
        console.log(e)
      })
  }
}

function insertCollectionHandler(collection, key) {
  return (req, res) => {
    // _id
    // id (autoincrementing id)
    // owner_id (fk)
    // location (geoJSON point)
    // image (url string)
    // nickname (string)
    // comment (string)
    // upvotes (integer)
    // downvotes (integer)

    getNextId(key)
      .then(function(id) {
        return collection.insert({
          id: id,
          owner_id: req.user._id,
          location: {
            type: 'Point',
            coordinates: [
              req.body.lng,
              req.body.lat
            ]
          },
          image: req.body.image,
          nickname: req.body.nickname,
          comment: req.body.comment,
          upvotes: 0,
          downvotes: 0,
          created_at: new Date()
        })
      })
      .then(function(result) {
        res.json(result)
      })
      .catch(onError(res))

      // @TODO(shrugs) - post new count to twitter
  }
}

app.get('/rocks', getCollectionHandler(rocks))

app.get('/notrocks', getCollectionHandler(notrocks))

app.get('/nearbyrocks', function(req, res) {
  // @TODO(shrugs) - implement actual location search
  rocks
    .find({
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [
              parseFloat(req.query.lng),
              parseFloat(req.query.lat)
            ]
          },
          $maxDistance: Math.max(
            parseInt(req.query.radius) || 500,
            5000
          ),
          $minDistance: 0
        }
      }
    })
    .sort({ created_at: -1 }).toArray()
    .then(function(rocks) {
      // for each rock, load the user
      return Promise
        .all(rocks.map(function(rock) {
          if (!rock.owner_id) {
            return Promise.resolve(rock)
          }
          return users.findOne({
            _id: ObjectID(rock.owner_id)
          })
          .then(function(user) {
            return Object.assign(rock, {
              owner: user
            })
          })
        }))
    })
    .then(function(rocks) {
      res.json(rocks)
    })
    .catch(onError(res))
})

app.post('/rocks', insertCollectionHandler(rocks, 'rock'))

app.post('/notrocks', insertCollectionHandler(notrocks, 'notrock'))

app.post('/rock/:id/discover', function(req, res) {
  rocks.findAndModify({
    query: { _id: ObjectID(req.params.id) },
    update: { $set: { owner_id: req.user._id } },
    new: true
  })
  .then(function(ret) {
    var rock = ret.value
    return users.findOne({
      _id: ObjectID(rock.owner_id)
    })
    .then(function(user) {
      return Object.assign(rock, {
        owner: user
      })
    })
  })
  .then(function(rock) {
    res.json(rock);
  })
  .catch(onError(res))
})

app.get('/rock/:id', function(req, res) {
  rocks
    .findOne({ _id: ObjectID(req.params.id) })
    .then(rock => {
      return users.findOne({
        _id: ObjectID(rock.owner_id)
      })
      .then(function(user) {
        return Object.assign(rock, {
          owner: user
        })
      })
    })
    .then(rock => {
      res.json(rock)
    })
    .catch(onError(res))
})

var port = process.env.PORT || 3000
app.listen(port, function () {
  console.log('Running on 0.0.0.0:' + port)
})
