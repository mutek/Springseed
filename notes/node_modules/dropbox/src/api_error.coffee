# Information about a failed call to the Dropbox API.
class Dropbox.ApiError
  # @property {Number} the HTTP error code (e.g., 403); compare against the
  #   constants defined on Dropbox.ApiError
  status: undefined

  # @property {String} the HTTP method of the failed request (e.g., 'GET')
  method: undefined

  # @property {String} the URL of the failed request
  url: undefined

  # @property {?String} the body of the HTTP error response; can be null if
  #   the error was caused by a network failure or by a security issue
  responseText: undefined

  # @property {?Object} the result of parsing the JSON in the HTTP error
  #   response; can be null if the API server didn't return JSON, or if the
  #   HTTP response body is unavailable
  response: undefined

  # Status value indicating an error at the XMLHttpRequest layer.
  #
  # This indicates a network transmission error on modern browsers. Internet
  # Explorer might cause this code to be reported on some API server errors.
  @NETWORK_ERROR: 0

  # Status value indicating an invalid input parameter.
  #
  # response.error should indicate which input parameter is invalid and why.
  @INVALID_PARAM: 400

  # Status value indicating an expired or invalid OAuth token.
  #
  # The OAuth token used for the request will never become valid again, so the
  # user should be re-authenticated.
  #
  # The authState of a Dropbox.Client will automatically transition from DONE
  # to ERROR when this error is received.
  @INVALID_TOKEN: 401

  # Status value indicating a malformed OAuth request.
  #
  # This indicates a bug in dropbox.js and should never occur under normal
  # circumstances. However, a Safari bug causes this status to be reported
  # instead of INVALID_TOKEN.
  @OAUTH_ERROR: 403

  # Status value indicating that a file or path was not found in Dropbox.
  #
  # This happens when trying to read from a non-existing file, readdir a
  # non-existing directory, write a file into a non-existing directory, etc.
  @NOT_FOUND: 404

  # Status value indicating that the HTTP method is not supported for the call.
  #
  # This indicates a bug in dropbox.js and should never occur under normal
  # circumstances.
  @INVALID_METHOD: 405

  # Status value indicating that the application is making too many requests.
  #
  # Rate-limiting can happen on a per-application or per-user basis.
  @RATE_LIMITED: 503

  # Status value indicating that the user's Dropbox is over its storage quota.
  #
  # The application UI should communicate to the user that their data cannot be
  # stored in Dropbox.
  @OVER_QUOTA: 507

  # Wraps a failed XHR call to the Dropbox API.
  #
  # @param {String} method the HTTP verb of the API request (e.g., 'GET')
  # @param {String} url the URL of the API request
  # @param {XMLHttpRequest} xhr the XMLHttpRequest instance of the failed
  #   request
  constructor: (xhr, @method, @url) ->
    @status = xhr.status
    if xhr.responseType
      try
        text = xhr.response or xhr.responseText
      catch xhrError
        try
          text = xhr.responseText
        catch xhrError
          text = null
    else
      try
        text = xhr.responseText
      catch xhrError
        text = null

    if text
      try
        @responseText = text.toString()
        @response = JSON.parse text
      catch xhrError
        @response = null
    else
      @responseText = '(no response)'
      @response = null

  # Used when the error is printed out by developers.
  toString: ->
    "Dropbox API error #{@status} from #{@method} #{@url} :: #{@responseText}"

  # Used by some testing frameworks.
  inspect: ->
    @toString()
