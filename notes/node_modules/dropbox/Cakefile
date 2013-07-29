async = require 'async'
{spawn, exec} = require 'child_process'
fs = require 'fs'
glob = require 'glob'
log = console.log
path = require 'path'
remove = require 'remove'

# Node 0.6 compatibility hack.
unless fs.existsSync
  fs.existsSync = (filePath) -> path.existsSync filePath


task 'build', ->
  build()

task 'test', ->
  vendor ->
    build ->
      ssl_cert ->
        tokens ->
          test_cases = glob.sync 'test/js/**/*_test.js'
          test_cases.sort()  # Consistent test case order.
          run 'node_modules/.bin/mocha --colors --slow 200 --timeout 20000 ' +
              "--require test/js/helpers/setup.js #{test_cases.join(' ')}"

task 'webtest', ->
  vendor ->
    build ->
      ssl_cert ->
        tokens ->
          webtest()

task 'cert', ->
  remove.removeSync 'test/ssl', ignoreMissing: true
  ssl_cert()

task 'vendor', ->
  remove.removeSync './test/vendor', ignoreMissing: true
  vendor()

task 'tokens', ->
  remove.removeSync './test/token', ignoreMissing: true
  build ->
    tokens ->
      process.exit 0

task 'doc', ->
  run 'node_modules/.bin/codo src'

task 'extension', ->
  run 'node_modules/.bin/coffee --compile test/chrome_extension/*.coffee'

task 'chrome', ->
  vendor ->
    build ->
      buildChromeApp 'app_v1'

task 'chrome2', ->
  vendor ->
    build ->
      buildChromeApp 'app_v2'

task 'chrometest', ->
  vendor ->
    build ->
      buildChromeApp 'app_v1', ->
        testChromeApp()

task 'chrometest2', ->
  vendor ->
    build ->
      buildChromeApp 'app_v2', ->
        testChromeApp()

task 'cordova', ->
  vendor ->
    build ->
      buildCordovaApp()

task 'cordovatest', ->
  vendor ->
    build ->
      buildCordovaApp ->
        testCordovaApp()

build = (callback) ->
  commands = []

  # Ignoring ".coffee" when sorting.
  # We want "driver.coffee" to sort before "driver-browser.coffee"
  source_files = glob.sync 'src/**/*.coffee'
  source_files.sort (a, b) ->
    a.replace(/\.coffee$/, '').localeCompare b.replace(/\.coffee$/, '')

  # Compile without --join for decent error messages.
  commands.push 'node_modules/.bin/coffee --output tmp --compile ' +
                source_files.join(' ')
  commands.push 'node_modules/.bin/coffee --output lib --compile ' +
                "--join dropbox.js #{source_files.join(' ')}"
  # Minify the javascript, for browser distribution.
  commands.push 'cd lib && ../node_modules/.bin/uglifyjs --compress ' +
      '--mangle --output dropbox.min.js --source-map dropbox.min.map ' +
      'dropbox.js'

  # Tests are supposed to be independent, so the build order doesn't matter.
  test_dirs = glob.sync 'test/src/**/'
  for test_dir in test_dirs
    out_dir = test_dir.replace(/^test\/src\//, 'test/js/')
    test_files = glob.sync path.join(test_dir, '*.coffee')
    commands.push "node_modules/.bin/coffee --output #{out_dir} " +
                  "--compile #{test_files.join(' ')}"
  async.forEachSeries commands, run, ->
    callback() if callback

webtest = (callback) ->
  webFileServer = require './test/js/helpers/web_file_server.js'
  if 'BROWSER' of process.env
    if process.env['BROWSER'] is 'false'
      url = webFileServer.testUrl()
      console.log "Please open the URL below in your browser:\n    #{url}"
    else
      webFileServer.openBrowser process.env['BROWSER']
  else
    webFileServer.openBrowser()
  callback() if callback?

ssl_cert = (callback) ->
  fs.mkdirSync 'test/ssl' unless fs.existsSync 'test/ssl'
  if fs.existsSync 'test/ssl/cert.pem'
    callback() if callback?
    return

  run 'openssl req -new -x509 -days 365 -nodes -batch ' +
      '-out test/ssl/cert.pem -keyout test/ssl/cert.pem ' +
      '-subj /O=dropbox.js/OU=Testing/CN=localhost ', callback

vendor = (callback) ->
  # All the files will be dumped here.
  fs.mkdirSync 'test/vendor' unless fs.existsSync 'test/vendor'

  # Embed the binary test image into a 7-bit ASCII JavaScript.
  buffer = fs.readFileSync 'test/binary/dropbox.png'
  bytes = (buffer.readUInt8(i) for i in [0...buffer.length])
  browserJs = "window.testImageBytes = [#{bytes.join(', ')}];\n"
  fs.writeFileSync 'test/vendor/favicon.browser.js', browserJs
  workerJs = "self.testImageBytes = [#{bytes.join(', ')}];\n"
  fs.writeFileSync 'test/vendor/favicon.worker.js', workerJs

  downloads = [
    # chai.js ships different builds for browsers vs node.js
    ['http://chaijs.com/chai.js', 'test/vendor/chai.js'],
    # sinon.js also ships special builds for browsers
    ['http://sinonjs.org/releases/sinon.js', 'test/vendor/sinon.js'],
    # ... and sinon.js ships an IE-only module
    ['http://sinonjs.org/releases/sinon-ie.js', 'test/vendor/sinon-ie.js']
  ]
  async.forEachSeries downloads, download, ->
    callback() if callback

testChromeApp = (callback) ->
  # Clean up the profile.
  fs.mkdirSync 'test/chrome_profile' unless fs.existsSync 'test/chrome_profile'

  # TODO(pwnall): remove experimental flag when the identity API gets stable
  command = "\"#{chromeCommand()}\" --load-extension=test/chrome_app " +
      '--enable-experimental-extension-apis ' +
      '--user-data-dir=test/chrome_profile --no-default-browser-check ' +
      '--no-first-run --no-service-autorun --disable-default-apps ' +
      '--homepage=about:blank --v=-1'

  run command, ->
    callback() if callback

buildChromeApp = (manifestFile, callback) ->
  buildStandaloneApp "test/chrome_app", ->
    run "cp test/chrome_app/manifests/#{manifestFile}.json " +
        'test/chrome_app/manifest.json', ->
      callback() if callback

buildStandaloneApp = (appPath, callback) ->
  unless fs.existsSync appPath
    fs.mkdirSync appPath
  unless fs.existsSync "#{appPath}/test"
    fs.mkdirSync "#{appPath}/test"
  unless fs.existsSync "#{appPath}/node_modules"
    fs.mkdirSync "#{appPath}/node_modules"

  links = [
    ['lib', "#{appPath}/lib"],
    ['node_modules/mocha', "#{appPath}/node_modules/mocha"],
    ['node_modules/sinon-chai', "#{appPath}/node_modules/sinon-chai"],
    ['test/token', "#{appPath}/test/token"],
    ['test/binary', "#{appPath}/test/binary"],
    ['test/html', "#{appPath}/test/html"],
    ['test/js', "#{appPath}/test/js"],
    ['test/vendor', "#{appPath}/test/vendor"],
  ]
  commands = for link in links
    "cp -r #{link[0]} #{path.dirname(link[1])}"
  async.forEachSeries commands, run, ->
    callback() if callback

chromeCommand = ->
  paths = [
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary',
    '/Applications/Chromium.app/MacOS/Contents/Chromium',
  ]
  for path in paths
    return path if fs.existsSync path

  if process.platform is 'win32'
    'chrome'
  else
    'google-chrome'

testCordovaApp = (callback) ->
  run 'test/cordova_app/cordova/run', ->
    callback() if callback

buildCordovaApp = (callback) ->
  if fs.existsSync 'test/cordova_app/www'  # iOS
    appPath = 'test/cordova_app/www'
  else if fs.existsSync 'test/cordova_app/assets/www'  # Android
    appPath = 'test/cordova_app/assets/www'
  else
    throw new Error 'Cordova www directory not found'

  buildStandaloneApp appPath, ->
    cordova_js = glob.sync("#{appPath}/cordova-*.js").sort().
                      reverse()[0]
    run "cp #{cordova_js} #{appPath}/test/js/platform.js", ->
      run "cp test/html/cordova_index.html #{appPath}/index.html", ->
        callback() if callback

tokens = (callback) ->
  TokenStash = require './test/js/helpers/token_stash.js'
  tokenStash = new TokenStash
  (new TokenStash()).get ->
    callback() if callback?

run = (args...) ->
  for a in args
    switch typeof a
      when 'string' then command = a
      when 'object'
        if a instanceof Array then params = a
        else options = a
      when 'function' then callback = a

  command += ' ' + params.join ' ' if params?
  cmd = spawn '/bin/sh', ['-c', command], options
  cmd.stdout.on 'data', (data) -> process.stdout.write data
  cmd.stderr.on 'data', (data) -> process.stderr.write data
  process.on 'SIGHUP', -> cmd.kill()
  cmd.on 'exit', (code) -> callback() if callback? and code is 0

download = ([url, file], callback) ->
  if fs.existsSync file
    callback() if callback?
    return

  run "curl -o #{file} #{url}", callback
