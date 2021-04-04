# Plex snoop

Sets up a Plex Media Server MITMd by [`mitmproxy`](https://mitmproxy.org/) with the aim of learning more about how the
PMS talks to Plex.tv and other upstream services (metadata, avatars, analytics, etc).

This is in service of project I am building which needs to talk to the undocumented Plex.tv APIs. You are welcome to
use it too.

See [`docs/API.md`](docs/API.md) for some of the requests I'm trying to document.

## Usage

Make sure you have Firefox installed, as the `snoop.rb` script opens a Firefox instance configured with the proxy so
that you can snoop Plex Web traffic too.

``` sh-session
$ ruby ./snoop.rb
```

The `docker-compose.yml` sets a default view filter for `mitmproxy` to hide some noisy and irrelevant requests:

```
! ( ~a | ~m OPTIONS | ~t html | ~t woff2 | ~c 301 | ~d google.com | ~d facebook | ~d gstatic.com | ~d mozilla | ~d firefox | ~d sentry | ~d transifex.net | ~d digicert | /wp-content/ | resources-cdn )
```

This hides all assets (JS, CSS, images, etc), all HTML responses (I only care about API calls), redirects, and several
domains related to the auth pages that Plex Web shows or Firefox internals.

You'll have to remove it from `docker-compose.yml`, edit it to what you want, or use "Edit Options" after `mitmweb`
boots to see requests which are hidden.

Additionally, it can be helpful to delineate PMS requests from Plex Web requests. I don't know if I can auto-configure
this, but setting the "Highlight" field to the following filter will highlight non-Firefox requests:

```
! ~hq "User-Agent.*Firefox"
```

## License

```
Copyright 2021 Bo Jeanes

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
