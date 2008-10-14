#!/bin/sh
cd `dirname $0`
exec erl +Bc +K true -smp auto \
    -conf priv/skel \
    -pa $PWD/ebin $PWD/lib/*/ebin \
    -boot start_sasl \
    -name skel \
    -s reloader \
    -s skel
