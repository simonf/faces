express = require('express')
db = require('./imgdb.js')

app = express()
#app.use express.session {secret: "n0n53n53"}
app.use express.methodOverride()
app.use express.bodyParser()
#app.use express.logger()

app.use '/public', express.static __dirname + '/public'
app.use '/favicon.ico', express.static __dirname + '/public/img/favicon.ico'


#List all categories
app.get '/happy', (req,res) ->
  db.getHappyCount(res)

app.get '/sad', (req,res) ->
  db.getSadCount(res)

app.get '/happy/:id', (req,res) ->
  db.getHappyImage(res,req.params.id)

app.get '/sad/:id', (req,res) ->
  db.getSadImage(res,req.params.id)

app.listen 3000
