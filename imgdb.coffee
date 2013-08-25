fs = require('fs')

root = exports ? this

happydir = 'public/happy/'
saddir = 'public/sad/'

root.getHappyCount = (res) ->
  getFileCount(res,happydir)

root.getSadCount = (res) ->
  getFileCount(res,saddir)

getFileCount = (res,dir) ->
  fs.readdir dir, (err, files) ->
    res.send {count: files.length}

