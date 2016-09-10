'use strict';

var express = require('express')
var app = express()
var pmongo = require('promised-mongo')

var dbHost = 'localhost' || process.env.MONGO_HOST
var dbPort = '27017' || process.env.MONGO_PORT
var dbName = 'howmanyrocks' || process.env.MONGO_DATABASE_NAME

var db = pmongo(dbHost + ':' + dbPort + '/' + dbName, ['counters', 'rocks'])
var counters = db.collection('counters')
var rocks = db.collection('rocks')

/**
 * Express Middleware
 */
app.use(require('body-parser').json())

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

/**
 * Routes
 */
app.get('/user/:id', function(req, res) {
  // @TODO(shrugs) return data for user
})

app.post('/users', function(req, res) {
  // @TOOD(shrugs) create a user and return the user's data
})

app.get('/rocks', function(req, res) {
  // @TODO(shrugs) return a list of all of the rocks
  rocks.find({}).toArray()
    .then(function(rocks) {
      res.json(rocks)
    })
})

app.get('/rock/:id', function(req, res) {
  // @TODO(shrugs) return data for a specific rock
})

app.post('/rocks', function(req, res) {
  // @TODO(shrugs) create a rock in the database
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
        // owner_id: req.user._id,
        lat: req.body.lat,
        lng: req.body.lng,
        image: req.body.image,
        nickname: req.body.nickname,
        comment: req.body.comment,
        upvotes: 0,
        downvotes: 0
      })
    })
    .then(function(newRock) {
      res.json(newRock)
    })
    .catch(onError(res))
})

app.post('/rock/:id/upvote', function(req, res) {
  // @TODO(shrugs) upvote a rock
})

app.post('/rock/:id/downvote', function(req, res) {
  // @TODO(shrugs) downvote a rock
})

var port = 3000 || process.env.PORT
app.listen(port, function () {
  console.log('Running on 0.0.0.0:' + port)
})
