csup = require('./csuplib')
config = csup.config

googleapis = require("googleapis")
rl = require("readline").createInterface(
  input: process.stdin
  output: process.stdout
)

auth = new googleapis.OAuth2Client(config.clientID, config.clientSecret, config.redirectURL)

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

  console.log "Visit the url:"
  console.log url
  rl.question "Enter the code here: ", getAccessToken