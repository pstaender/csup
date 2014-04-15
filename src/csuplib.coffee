YAML        = require('yamljs')
_           = require('underscore')
fs          = require('fs')
googleapis  = require("googleapis")
argv        = require('optimist').argv

GoogleTokenProvider = require("refresh-token").GoogleTokenProvider

_rl = null

absPath = (p) ->
  home = process.env['HOME'] or process.env['USERPROFILE']
  p?.replace(/\~\//g, home+"/")#?.replace(/^\.\//, process.argv[1]+'/')

mask = (s) ->
  return '***' unless typeof s is 'string'
  if s.length > 2
    s[0] + Array(s.length-1).join('*') + s[s.length-1]
  else
    Array(s.length+1).join('*')

exports.log = (verbosity = 0, msg) ->
  if exports.config.verbosity >= verbosity
    console.log(msg) if msg isnt null or undefined
    true
  else
    false

exports.configFile = argv.c or argv.config or '~/.csup'
exports.configFile = absPath(exports.configFile)

exports.rl = ->
  return _rl if _rl
  _rl = require("readline").createInterface { input: process.stdin, output: process.stdout }

exports.defaultOptions =
  scope: "https://www.googleapis.com/auth/drive.file"
  authCode: ""
  accessToken: ""
  clientID: ""
  clientSecret: ""
  redirectURL: 'http://localhost'
  refreshToken: ""
  defaultFilename: 'file_{timestamp}' # possible is {date|DATE|timestamp|TIMESTAMP}

exports.loadConfig = ->
  unless fs.existsSync(exports.configFile)
    null
  else
    _.defaults(YAML.load(exports.configFile) or {}, exports.defaultOptions)

exports.config = exports.loadConfig() or {}

exports.defaultFilename = ->
  s = exports.config.defaultFilename?.trim() or exports.defaultOptions.defaultFilename
  s.replace('{timestamp}', new Date().getTime()).replace('{TIMESTAMP}', Math.round((new Date().getTime())/1000)).replace('{date}', String(new Date())).replace('{DATE}', String(new Date()).replace(/\s+/g,'_'))

exports.storeConfig = (cb) ->
  c = exports.loadConfig() or {}
  # only store some specific values
  c.authCode = exports.config.authCode or null
  c.accessToken = exports.config.accessToken or null
  c.clientID = exports.config.clientID or null
  c.clientSecret = exports.config.clientSecret or null
  c.accessToken = exports.config.accessToken or null
  c.refreshToken = exports.config.refreshToken or null
  c.tokenType = exports.config.tokenType or null
  if typeof cb is 'function'
    fs.writeFile(exports.configFile, YAML.stringify(c, 2), cb)
  else
    fs.writeFileSync(exports.configFile, YAML.stringify(c, 2))

exports.credentials = ->
  { access_token: exports.config.accessToken, refresh_token: exports.config.refreshToken, token_type: exports.config.tokenType }

exports.setup = ->
  exports.config = _.defaults(exports.loadConfig() or {}, exports.defaultOptions)
  console.log """
    ** SETUP CLIENT_ID AND CLIENT_SECRET **

    For more informations how to create api keys visit:
    https://developers.google.com/console/help/#generatingdevkeys

    Examples:

    clientID: 123455-abc38rwfds.apps.googleusercontent.com
    clientSecret: 1wnchd7Xjs-d7ucnJHSXJK

    Leave empty to keep previous values

"""
  setupClientTokens = ->
    rl = exports.rl()
    rl.question "clientID: ", (clientID) ->
      exports.config.clientID = clientID if clientID
      rl.question "clientSecret: ", (clientSecret) ->
        exports.config.clientSecret = clientSecret if clientSecret
        console.log """
        clientSecret: '#{exports.config.clientSecret}'
        clientID:     '#{exports.config.clientID}'
        """
        rl.question "Is that correct? (Y/n) ", (yesOrNo) ->
          if /^\s*[nN]+\s*/.test(yesOrNo) or not exports.config.clientSecret or not exports.config.clientID
            console.error('ERROR: clientID and clientSecret must be a valid value\n') if not exports.config.clientSecret or not exports.config.clientID
            setupClientTokens()
          else
            exports.storeConfig()
            console.log "Values stored in '#{exports.configFile}'"
            rl.question "Do want to start the auth process? (Y/n) ", (yesOrNo) ->
              if /^\s*[nN]+\s*/.test(yesOrNo)
                process.exit(0)
              else
                require('./auth')

  setupClientTokens()

exports.checkConfig = ->
  unless exports.config.clientID or not exports.config.clientSecret
    console.error "Couldn't read config file '#{exports.configFile}'."
    console.error "Run setup with:\ncsup setup"
    process.exit(1)
  else
    try
      unless exports.config
        return exports.loadConfig()
      else
        return exports.config
    catch e
      console.error "Could't parse yaml config file '#{exports.configFile}':", e?.message or e, "Please fix or remove config file."
      process.exit(1)

exports.help = ->
  """
    csup v0.0.2 (cloud storage uploader), (c) 2014 by Philipp Staender

    Usage: csup (switch) (-option|--option)

    switches:
      auth        receives `accessToken` from Google API (interactive)
      setup       setups `clientID` + `clientSecret` (interactive)

    options:
      -h --help   displays help
      -n --name   filename for cloud storage    e.g. -n filename.txt
      -t --type   force a specific filetype     e.g. -t 'application/zip'
      -v -vv -vvv verbosity
  """

exports.establishAPIConnection = (cb) ->
  googleapis = require("googleapis")
  config = exports.config

  tokenProvider = new GoogleTokenProvider
    'refresh_token': config.refreshToken
    'client_id': config.clientID
    'client_secret': config.clientSecret

  tokenProvider.getToken (err, accessToken) ->
    config.accessToken = accessToken

    unless accessToken
      console.error """
        Couldn't get valid accesstoken. Please run again:
        csup auth
      """
      process.exit(1)
    # store asnyc
    exports.storeConfig (err) ->
      console.error("Couldn't store config", err?.message or err) if err

    auth = new googleapis.OAuth2Client(config.clientID, config.clientSecret, config.redirectURL)
    cb(err, googleapis, auth)
