'use strict';

require('dotenv').config({silent: true});

var express = require('express')
var app = express()
var pmongo = require('promised-mongo')
var ObjectID = pmongo.ObjectId
var crypto = require('crypto')
var images = require('./images')

var dbHost = process.env.MONGO_HOST || 'localhost'
var dbPort = process.env.MONGO_PORT || '27017'
var dbName = process.env.MONGO_DATABASE_NAME || 'howmanyrocks'

var db = pmongo(dbHost + ':' + dbPort + '/' + dbName, ['counters', 'rocks', 'users'])
var counters = db.collection('counters')
var rocks = db.collection('rocks')
var notrocks = db.collection('notrocks')
var users = db.collection('users')

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

/**
 * Routes
 */
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
    username: req.body.username,
    token: crypto.randomBytes(64).toString('hex'),
    image: randomPicture()
  })
  .then(function(user) {
    res.json(user);
  })
})

app.get('/valid-username', function(req, res) {
  // @TODO(shrugs) req.query.username
  res.json({
    valid: true
  })
})

app.get('/rocks', function(req, res) {
  rocks.find({}).sort({ created_at: -1 }).toArray()
    .then(function(rocks) {
      // for each rock, load the user
      Promise
        .all(rocks.map(function(rock) {
          if (!rock.owner_id) {
            return rock
          }
          // fuck performance lol
          return users.findOne({
            _id: ObjectID(rock.owner_id)
          })
          .then(function(user) {
            return Object.assign(rock, {
              owner: user
            })
          })
        }))
        .then(function(rocks) {
          res.json(rocks)
        })
    })
})

app.get('/notrocks', function(req, res) {
  notrocks.find({}).sort({ created_at: -1 }).toArray()
    .then(function(notrocks) {
      // for each rock, load the user
      Promise
        .all(notrocks.map(function(rock) {
          if (!rock.owner_id) {
            return rock
          }
          // fuck performance lol
          return users.findOne({
            _id: ObjectID(rock.owner_id)
          })
          .then(function(user) {
            return Object.assign(rock, {
              owner: user
            })
          })
        }))
        .then(function(rocks) {
          res.json(rocks)
        })
    })
})

app.post('/rocks', function(req, res) {
  // _id
  // id (autoincrementing id)
  // owner_id (fk)
  // lat (float)
  // lng (float)
  // location_name (string)
  // image (url string)
  // nickname (string)
  // comment (string)
  // upvotes (integer)
  // downvotes (integer)

  // @TODO(shrugs) - reverse geocode location
  getNextId('rock')
    .then(function(id) {
      return rocks.insert({
        id: id,
        owner_id: req.user._id,
        lat: req.body.lat,
        lng: req.body.lng,
        image: req.body.image,
        nickname: req.body.nickname,
        comment: req.body.comment,
        upvotes: 0,
        downvotes: 0,
        created_at: new Date()
      })
    })
    .then(function(newRock) {
      res.json(newRock)
    })
    .catch(onError(res))

    // @TODO(shrugs) - post new count to twitter
})


app.post('/notrocks', function(req, res) {
  // @TODO(shrugs) - reverse geocode location
  getNextId('rock')
    .then(function(id) {
      return notrocks.insert({
        id: id,
        owner_id: req.user._id,
        lat: req.body.lat,
        lng: req.body.lng,
        image: req.body.image,
        upvotes: 0,
        downvotes: 0,
        created_at: new Date()
      })
    })
    .then(function(newRock) {
      res.json(newRock)
    })
    .catch(onError(res))

    // @TODO(shrugs) - post new count to twitter
})

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
})

app.post('/rock/:id/upvote', function(req, res) {
  // @TODO(shrugs) upvote a rock
  rocks.findAndModify({
    query: { _id: ObjectID(req.params.id) },
    update: { $inc: { upvotes: 1 } },
    new: true
  })
  .then(function(rock) {
    res.json(rock);
  })
})

app.post('/rock/:id/downvote', function(req, res) {
  // @TODO(shrugs) downvote a rock
  rocks.findAndModify({
    query: { _id: ObjectID(req.params.id) },
    update: { $inc: { downvotes: 1 } },
    new: true
  })
  .then(function(rock) {
    res.json(rock);
  })
})

var port = 3000 || process.env.PORT
app.listen(port, function () {
  console.log('Running on 0.0.0.0:' + port)
})
