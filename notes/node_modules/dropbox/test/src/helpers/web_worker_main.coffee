# This runs tests inside a Web Worker.

importScripts '../../../lib/dropbox.js'

importScripts '../../../test/vendor/sinon.js'
importScripts '../../../test/vendor/chai.js'
importScripts '../../../node_modules/sinon-chai/lib/sinon-chai.js'
importScripts '../../../node_modules/mocha/mocha.js'
importScripts '../../../test/js/helpers/browser_mocha_setup.js'

importScripts '../../../test/token/token.worker.js'
importScripts '../../../test/vendor/favicon.worker.js'
importScripts '../../../test/js/helpers/setup.js'

importScripts '../../../test/js/api_error_test.js'
importScripts '../../../test/js/base64_test.js'
importScripts '../../../test/js/client_test.js'
# NOTE: not loading the auth driver tests, no driver works in a Web Worker.
importScripts '../../../test/js/event_source_test.js'
importScripts '../../../test/js/hmac_test.js'
importScripts '../../../test/js/oauth_test.js'
importScripts '../../../test/js/pulled_changes_test.js'
importScripts '../../../test/js/range_info_test.js'
importScripts '../../../test/js/references_test.js'
importScripts '../../../test/js/stat_test.js'
importScripts '../../../test/js/upload_cursor_test.js'
importScripts '../../../test/js/user_info_test.js'
# NOTE: not loading web_worker_test.js, to allow Worker debugging with it.only
importScripts '../../../test/js/xhr_test.js'

# NOTE: not loading helpers/browser_mocha_runner, using the code below instead.

# Fire the tests when we get the "go" message.
self.onmessage = (event) ->
  message = event.data
  switch message.type
    when 'go'
      mocha.run()
