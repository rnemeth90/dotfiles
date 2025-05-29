#!/bin/bash

URL="${1:-https://qa2.rc.aprimo.com/MarketingOps/assets/v2/normal.e6024bb380bf27e1.css}"

echo "==> Testing: Accept-Encoding: br"
curl -s -H "Accept-Encoding: br" -o /dev/null -D - "$URL" | grep -i Content-Encoding

echo "==> Testing: Accept-Encoding: gzip"
curl -s -H "Accept-Encoding: gzip" -o /dev/null -D - "$URL" | grep -i Content-Encoding

echo "==> Testing: Accept-Encoding: gzip, br"
curl -s -H "Accept-Encoding: gzip, br" -o /dev/null -D - "$URL" | grep -i Content-Encoding

echo "==> Testing: Accept-Encoding: br, gzip"
curl -s -H "Accept-Encoding: br, gzip" -o /dev/null -D - "$URL" | grep -i Content-Encoding

echo "==> Testing: No Accept-Encoding header"
curl -s -o /dev/null -D - "$URL" | grep -i Content-Encoding
