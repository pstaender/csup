request             = require('request')
csup                = require('./csuplib')
contentTypes        = require('./contenttypes')
GoogleTokenProvider = require("refresh-token").GoogleTokenProvider

config = csup.checkConfig()
log = csup.log

return csup.setup() unless config
# console.log(config)
# process.exit(0)
googleapis = require("googleapis")

tokenProvider = new GoogleTokenProvider
  'refresh_token': config.refreshToken
  'client_id': config.clientID
  'client_secret': config.clientSecret

tokenProvider.getToken (err, accessToken) ->
  config.accessToken = accessToken

  unless accessToken
    console.error "Couldn't get valid accesstoken. Please run again\ncsup auth"
    process.exit(1)
  # store asnyc
  csup.storeConfig (err) ->
    console.error("Couldn't store config", err?.message or err) if err

  auth = new googleapis.OAuth2Client(config.clientID, config.clientSecret, config.redirectURL)
  googleapis.discover("drive", "v2").execute (err, client) ->

    url = auth.generateAuthUrl(scope: config.scope)

    auth.credentials = csup.credentials()

    filename = config.filename or csup.defaultFilename()
    filetype = config.type or config.defaultType or contentTypes.getContentType(filename)

    process.stdin.pipe request.post
      url: "https://www.googleapis.com/upload/drive/v2/files"
      headers:
        Authorization: "Bearer " + config.accessToken
        "Content-Type": "#{filetype}; charset=UTF-8"
    , (err, res) ->
      size = 0
      try
        body = JSON.parse(res.body)
        fileSize = Math.round((Number(body.fileSize) / 8 / 1024 / 1024) * 100) / 100
        # .id, .md5checksum, .fileSize
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
          body.filename = filename # we add the filename here because it ain't renamed on cloud storage, yet

          log(1, {
            id: body.id
            filename: body.filename
            mimeType: body.mimeType
            downloadUrl: body.downloadUrl
            createdDate: body.createdDate
            modifiedDate: body.modifiedDate
            md5Checksum: body.md5Checksum
            fileSize: Number(body.fileSize)
            originalFilename: body.originalFilename
            ownerNames: body.ownerNames
          }) unless log(2, body)

          req.withAuthClient(auth).execute (err, res) ->
            log(0, fileID) unless log(1, "#{fileId}\t#{res.title}\t#{fileSize}mb")
            if err
              console.error 'Could not rename uploaded file'
              process.exit(1)
            else
              process.exit(0)


