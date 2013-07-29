# TODO(pwnall): enable tests when the PRs cited in the Workers bug get pulled.
#               https://github.com/dropbox/dropbox-js/issues/52
describe.skip 'Web Worker tests', ->
  if typeof window isnt 'undefined' and typeof window.Worker is 'function'
    it 'pass', (done) ->
      @timeout 3600000  # This test actually runs the whole suite in a Worker.

      worker = new Worker window.location.href.replace(/\/html\/.*$/,
          '/js/helpers/web_worker_main.js')
      worker.onmessage = (event) ->
        message = event.data
        switch message.type
          when 'pass'
            console.log 'WebWorker Test passed: ' + message.test.fullTitle
          when 'fail'
            console.warn 'WebWorker Test failed: ' + message.test.fullTitle
          when 'done'
            expect(message).to.have.property 'stats'
            expect(message.stats).to.have.property 'failures'
            expect(message.stats.failures).to.equal 0
            expect(message.stats).to.have.property 'passes'
            expect(message.stats.passes).to.be.greaterThan 0
            done()
      worker.onerror = (event) ->
        console.warn "WebWorker error: #{event.message} " +
                     "(#{event.filename}: #{event.lineno})"
        event.preventDefault() if event.preventDefault
      worker.postMessage type: 'go'
  else
    it.skip 'pass'
