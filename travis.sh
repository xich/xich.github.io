#!/bin/bash

# must be run after git submodule update --remote

set -ev

sourcetime=`git log -n1 --format="%at"`
mastertime=`( cd _site ; git log -n1 --format="%at" )`

if [ "$mastertime" -le "$sourcetime" ]
then
    echo "Building hakyll"
    cabal sandbox init
    cabal update
    cabal install --only-dependencies # need to figure out how to pull archive from somewhere

    echo "Building site"
    cabal run site -- build

    echo "Pushing site"
    cd _site
    git status
    git diff -b
    git add --all
    git config --global user.email "xichekolas@gmail.com"
    git config --global user.name "Andrew Farmer"
    ( git commit -m "travis deploy `date '+%m/%d/%y %H:%M'`" ; git push origin master) || true # in case no changes
else
    echo "Skipping rebuild because master is already newer than source."
fi
