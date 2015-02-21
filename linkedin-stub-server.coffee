url = Npm.require('url')
HttpInterceptor = Package['xolvio:http-interceptor'].HttpInterceptor

OAuth = Package['oauth'].OAuth

# From the github-fake package I take, that tt seems like some
# IronRouter versions have problems with the redirect_uri.
fixRedirectUri = (query) ->
  if query.redirect_uri.indexOf('http:/') isnt -1 and query.redirect_uri.indexOf('http://') is -1
    query.redirect_uri = query.redirect_uri.replace('http:/', 'http://')
  query

LinkedinStub =
  fakeData:
    oauthToken: 'C4fDpmAHHA7r0EZRBVJoIywoPMt64yMq'
    oauthVerifier: 'uE5YqPdfjh2hsMTR7L3MhDrEnzWKIRzE'
    oauthTokenSecret: 'Ct44BiqYSEt3vF2dBSkqVbviLIQMicIY'
    accessToken: '859186075-8RvREJv57qylZWN6UD3HyFAFxkTS6RPmMHnBN7tm'
    accessTokenSecret: 'K14oVfWunYuaqUPhEW6WkRkE7BKEAMO81qgh6tljrnIOb'
    identity:
      siteStandardProfileRequest:
        url: 'https:\/\/www.linkedin.com\/profile\/view?id=...'
      lastName: 'Maulwurf'
      id: '123456',
      headline: 'CEO of Much Profitable Company',
      firstName: 'Hans'
    extraData:
      threeCurrentPositions:
        values: [ {
          title: 'CEO'
          startDate:
            year: 2012
            month: 12
          isCurrent: true
          id: 1
          company:
            name: 'Much Profitable Company'
            id: 1
        } ]
        _total: 1
      skills:
        values: [
          { id: 6  , skill: { name: 'JavaScript' } }
          { id: 8  , skill: { name: 'HTML 5' } }
          { id: 9  , skill: { name: 'Meteor' } }
        ]
        _total: 2
      recommendationsReceived:
        _total: 0
      publicProfileUrl: 'https://www.linkedin.com/in/hansmaulwurf'
      pictureUrl: Meteor.absoluteUrl('images/maulwurf.jpg')
      numConnections: 1
      location:
        name: 'Berlin Area, Germany'
      emailAddress: 'h.maulwurf@much-profitable.com'

  init: ->
    HttpInterceptor.registerInterceptor('https://api.linkedin.com', Meteor.absoluteUrl('fake.api.linkedin.com'))
    HttpInterceptor.registerInterceptor('https://www.linkedin.com', Meteor.absoluteUrl('fake.www.linkedin.com'))

    authRoute = 'fake.www.linkedin.com/uas/oauth2/authorization'
    authCallback = ->
      parameters = fixRedirectUri(@request.query)
      @response.writeHead 302,
        Location: parameters.redirect_uri +
          '?state=' + parameters.state +
          '&oauth_token=' + LinkedinStub.fakeData.oauthToken +
          '&oauth_verifier=' + LinkedinStub.fakeData.oauthVerifier
      @response.end()

    tokenRoute = 'fake.api.linkedin.com/uas/oauth2/accessToken'
    tokenCallback = ->
      tokenResponse =
        'expires_in': 5184000,
        'access_token': LinkedinStub.fakeData.accessToken
      @response.writeHead(200, 'Content-Type': 'application/json;charset=utf-8')
      @response.end(JSON.stringify(tokenResponse))

    identRoute = 'fake.api.linkedin.com/v1/people/~'
    identCallback = ->
      @response.writeHead(200, 'Content-Type': 'application/json;charset=utf-8')
      @response.end(JSON.stringify(LinkedinStub.fakeData.identity));

    extraRoute = /fake.api.linkedin.com\/v1\/people\/~:\((.*)\)/
    extraCallback = ->
      @response.writeHead(200, 'Content-Type': 'application/json;charset=utf-8')
      @response.end(JSON.stringify(LinkedinStub.fakeData.extraData));

    Router.route authRoute,  authCallback,  where: 'server'
    Router.route tokenRoute, tokenCallback, where: 'server'
    Router.route identRoute, identCallback, where: 'server'
    Router.route extraRoute, extraCallback, where: 'server'

Meteor.startup ->
  ServiceConfiguration.configurations.remove(service: 'linkedin')
  ServiceConfiguration.configurations.insert
    service: 'linkedin'
    clientId: 'long_consumer_key'
    secret: 'a_really_big_secret'
    # Using `redirect`, which is easier when using webdriver as popup
    # are an annoyance to deal with.
    loginStyle: 'redirect'
  LinkedinStub.init()
