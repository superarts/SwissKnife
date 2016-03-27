#!/bin/bash
cp _posts/* ../superarts.github.io/_posts/
git add .
git commit -a -m "$1"
git push
cd ../superarts.github.io
git add .
git commit -a -m "$1"
git push