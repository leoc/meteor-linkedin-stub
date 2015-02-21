linkedinFakeOptions = (options) ->
  loopbackLoginUrl = new URL(options.loginUrl)
  # Change the protocol to `http` so we can run a loopback without
  # extra server configuration.
  loopbackLoginUrl.protocol = 'http'

  # Precede the host with fake.
  loopbackLoginUrl.pathname = 'fake.' +
    loopbackLoginUrl.host +
    loopbackLoginUrl.pathname

  # Loop back to the current app.
  loopbackLoginUrl.host = new URL(Meteor.absoluteUrl()).host

  options.loginUrl = loopbackLoginUrl.toString()
  options

# Intercept the URL out to the oauth service
_launchLogin = Package.oauth.OAuth.launchLogin
Package.oauth.OAuth.launchLogin = (options) ->
  args = [linkedinFakeOptions(options)]
  _launchLogin.apply(this, args)
