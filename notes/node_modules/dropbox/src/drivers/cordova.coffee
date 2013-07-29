# OAuth driver that uses a Cordova InAppBrowser to complete the flow.
class Dropbox.Drivers.Cordova extends Dropbox.Drivers.BrowserBase
  # Sets up an OAuth driver for Cordova applications.
  #
  # @param {?Object} options one of the settings below; leave out the argument
  #   to use the current location for redirecting
  # @option options {Boolean} rememberUser if true, the user's OAuth tokens are
  #   saved in localStorage; if you use this, you MUST provide a UI item that
  #   calls signOut() on Dropbox.Client, to let the user "log out" of the
  #   application
  # @option options {String} scope embedded in the localStorage key that holds
  #   the authentication data; useful for having multiple OAuth tokens in a
  #   single application
  constructor: (options) ->
    @rememberUser = options?.rememberUser or false
    @scope = options?.scope or 'default'

  # Shows the authorization URL in a pop-up, waits for it to send a message.
  doAuthorize: (authUrl, token, tokenSecret, callback) ->
    browser = window.open authUrl, '_blank', 'location=yes'
    promptPageLoaded = false
    authHost = /^[^/]*\/\/[^/]*\//.exec(authUrl)[0]
    onEvent = (event) ->
      if event.url is authUrl and promptPageLoaded is false
        # We get loadstop for the app authorization prompt page.
        # On phones, we get a 2nd loadstop for the same authorization URL
        # when the user clicks 'Allow'. On tablets, we get a different URL.
        promptPageLoaded = true
        return
      if event.url and event.url.substring(0, authHost.length) isnt authHost
        # The user clicked on the app URL. Wait until they come back.
        promptPageLoaded = false
        return
      if event.type is 'exit' or promptPageLoaded
        browser.removeEventListener 'loadstop', onEvent
        browser.removeEventListener 'exit', onEvent
        browser.close() unless event.type is 'exit'
        callback()
    browser.addEventListener 'loadstop', onEvent
    browser.addEventListener 'exit', onEvent

  # This driver does not use a redirect page.
  url: -> null

  # Discards tokens saved during the authentication process.
  onAuthStateChange: (client, callback) ->
    superCall = do => => super client, callback
    @setStorageKey client
    if client.authState is DropboxClient.RESET
      @loadCredentials (credentials) =>
        if credentials and credentials.authState  # Incomplete authentication.
          @forgetCredentials superCall
        else
          superCall()
    else
      superCall()
