#!/usr/bin/env node
// USAGE:
// Set environment var GH_TOKEN
// node members.js organization

var pumpify = require('pumpify')
var requestStream = require('requesturl-stream')
var ts = require('tool-stream')
var through = require('through2')
var request = require('request')
var parseLinkHeader = require('parse-link-header')

var TOKEN = process.env.GH_TOKEN

var APIROOT = 'https://api.github.com/'
var organization = process.argv[2]
var membersURL = APIROOT + 'orgs/' + organization + '/teams'

var requestOptions = {
  json: true,
  headers: {
    'Authorization': 'token ' + TOKEN,
    'User-Agent': 'request'
  }
}

var replaceStream = function (fromString, toString) {
  return through.obj(function (inputText, enc, next) {
    this.push(inputText.replace(fromString, toString))
    next()
  })
}

var paginateRequest = through.obj(function (obj, enc, next) {
  requestOptions.url = obj
  request(requestOptions, (err, res, json) => {
    if (err) { console.log(err) }
    this.push(json)
    var pages = parseLinkHeader(res.headers.link)
    if (pages && pages.next) {
      paginateRequest.write(pages.next.url)
    }
    next()
  })
})

var pipeline = pumpify.obj(
  requestStream(requestOptions),
  ts.arraySplit(), // 3 objects (i.e. 3 teams: Contributors, Core, GSoC16)
  ts.extractProperty('members_url'),
  replaceStream('{/member}', ''),
  paginateRequest,
  ts.JSONToBuffer(),
  process.stdout
)

pipeline.write(membersURL)
