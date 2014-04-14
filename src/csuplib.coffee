YAML = require('yamljs')
_ = require('underscore')
fs = require('fs')
googleapis = require("googleapis")

absPath = (p) ->
  home = process.env['HOME'] or process.env['USERPROFILE']
  p?.replace /\~\//g, home+"/"

configFile = absPath('~/.csup')

config = {}

exports.defaultOptions =
  scope: "https://www.googleapis.com/auth/drive.file"
  authCode: 0
  accessToken: 0
  clientID: 0
  clientSecret: 0
  redirectURL: 'http://localhost'
  refreshToken: 0
  defaultFilename: 'file_{timestamp}' # possible in {date|DATE|timestamp|TIMESTAMP}

exports.defaultFilename = ->
  s = config.defaultFilename?.trim() or exports.defaultOptions.defaultFilename
  s.replace('{timestamp}', new Date().getTime()).replace('{TIMESTAMP}', Math.round((new Date().getTime())/1000)).replace('{date}', String(new Date())).replace('{DATE}', String(new Date()).replace(/\s+/g,'_'))

exports.storeConfig = (cb) ->
  if typeof cb is 'function'
    fs.writeFile(configFile, YAML.stringify(config,2), cb)
  else
    fs.writeFileSync(configFile, YAML.stringify(config,2))

unless fs.existsSync(configFile)
  console.error "Couldn't load config file '#{configFile}'."
  try
    exports.storeConfig()
  catch e
    console.error "Error on creating file:", err?.message
  console.error "Created config file with empty values; please set up first to process. For instance:"
  console.error "vi #{configFile}"
  process.exit(1)

try
  exports.config = config = _.defaults(YAML.load(configFile), exports.defaultOptions)
catch e
  console.error "Could't parse yaml config file '#{configFile}':", e?.message or e
  process.exit(1)




exports.credentials = ->
  { access_token: config.accessToken, refresh_token: config.refreshToken, token_type: config.tokenType }
