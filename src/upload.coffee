request = require('request')
csup = require('./csuplib')
contentTypes = require('./contenttypes')
config = csup.config

googleapis = require("googleapis")
auth = new googleapis.OAuth2Client(config.clientID, config.clientSecret, config.redirectURL)

googleapis.discover("drive", "v2").execute (err, client) ->

  url = auth.generateAuthUrl(scope: config.scope)

  auth.credentials = csup.credentials()

  filename = config.filename or csup.defaultFilename()
  config.type = config.type or config.defaultType or contentTypes.getContentType(filename)

  process.stdin.pipe request.post
    url: "https://www.googleapis.com/upload/drive/v2/files"
    headers:
      Authorization: "Bearer " + config.accessToken
      "Content-Type": "#{config.type}; charset=UTF-8"
  , (err, res) ->
    try
      body = JSON.parse(res.body)
    catch e
      body = null
    if err
      console.error "Error during upload: ", err?.message or err or res?.body?.error
      process.exit(1)
    else
      if body?.error
        console.error 'Error from Google API: ', body?.error
        process.exit(1)
      else
        fileId = body.id
        req = client.drive.files.update({ fileId: fileId }, { title: filename })
        req.withAuthClient(auth).execute (err, res) ->
          if err
            console.log "* #{fileId}"
            console.error 'Could not rename uploaded file'
            process.exit(1)
          else
            console.log "* #{fileId} -> #{res.title}"
            process.exit(0)


