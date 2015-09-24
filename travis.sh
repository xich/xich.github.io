#!/bin/bash

# must be run after git submodule update --remote

set -ev

sourcetime=`git log -n1 --format="%at"`
mastertime=`( cd _site ; git log -n1 --format="%at" )`

if [ "$mastertime" -le "$sourcetime" ]
then
    # build hakyll
    cabal sandbox init
    cabal update
    cabal install --only-dependencies # need to figure out how to pull archive from somewhere

    # build site
    cabal run site -- build

    # push built site up to master
    cd _site
    git status
    git diff -b
    git add --all
    git config --global user.email "xichekolas@gmail.com"
    git config --global user.name "Andrew Farmer"
    git commit -m "travis deploy $(date '+%m/%d/%y %H:%M')"
    git push origin master
else
    echo "Skipping rebuild because master is already newer than source."
fi
