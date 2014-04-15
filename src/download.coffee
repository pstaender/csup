request             = require('request')
csup                = require('./csuplib')
contentTypes        = require('./contenttypes')

config = csup.checkConfig()
log = csup.log

return csup.setup() unless config

csup.establishAPIConnection (err, googleapis, auth) ->
  request.get({
    url: config.urlToDownload
    headers:
      Authorization: "Bearer #{config.accessToken}"
  }).pipe(process.stdout)
