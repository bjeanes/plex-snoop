#!/usr/bin/env sh
#
# This copies the mitmproxy root cert into Plex's cacert store so that we can intercept it's HTTPS traffic with plex.tv
#

set -ex

# Thanks https://bgstack15.wordpress.com/2020/11/01/plex-media-server-add-root-ca-cert-to-trusted-bundle/
cacert_store="/usr/lib/plexmediaserver/Resources/cacert.pem"
orig_store="$cacert_store.orig"

if [ ! -f "$orig_store" ]; then
  mv -v "$cacert_store" "$orig_store"
fi

cp -fv "$orig_store" "$cacert_store"

while [ ! -f "/mitmproxy/mitmproxy-ca-cert.pem" ]; do
  echo Waiting for mitmproxy to generate CA certificate
  sleep 2
done

echo Installing mitmproxy CA cert
cat "/mitmproxy/mitmproxy-ca-cert.pem" | tee -a "$cacert_store"
