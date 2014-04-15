csup        = require('./csuplib')
googleapis  = require("googleapis")

config = csup.checkConfig()
auth = new googleapis.OAuth2Client(config.clientID, config.clientSecret, config.redirectURL)

if not config.clientID or not config.clientSecret
  console.error "There are no valid clientID and clientSecret set in `#{csup.configFile}`, please complete values"
  process.exit(1)

console.log '** AUTH PROCESS **'

googleapis.discover("drive", "v2").execute (err, client) ->

  url = auth.generateAuthUrl(scope: config.scope)

  getAccessToken = (code) ->
    auth.getToken code, (err, tokens) ->
      if err
        console.error "Error while trying to retrieve access token", err
        process.exit(1)
      config.accessToken = tokens.access_token
      config.tokenType = tokens.token_type
      config.refreshToken = tokens.refresh_token
      csup.storeConfig()
      console.log "Succesfully persisted access token"
      process.exit(0)

  console.log "\n#{url}"
  csup.rl().question "\nVisit the url and enter the code here: ", getAccessToken
