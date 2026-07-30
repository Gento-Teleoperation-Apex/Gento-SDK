#!/bin/sh

kill -2 $(pidof FXUDP)
kill -2 $(pidof FXFileServer)
kill -2 $(pidof FXPSI)
sleep 1
rmmod FXSI
sleep 1
rmmod FXKMemory

