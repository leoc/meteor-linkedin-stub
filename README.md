LinkedIn Stub
============

A stub for use in testing Meteor apps. Stubs the oauth calls and allows you to fake stub more.

# Usage

If you are using Twitter authentication, add this package like this:

`meteor add leoc:linkedin-stub`

Your app will no longer authenticate with LinkedIn in development mode and will authenticate with
a fake user even if you do not have an internet connection. This package does not affect production
as it is a `debugOnly` package.

This package was based on [xolvio:meteor-twitter-stub](https://github.com/xolvio/meteor-twitter-stub).
