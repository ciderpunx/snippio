#!/bin/bash

cd /home/charlie/snipp
exec dist/build/snipp/snipp Production +RTS -N 2>&1>sniplog
