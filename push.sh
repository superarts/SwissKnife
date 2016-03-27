#!/bin/bash
cp _posts/* ../superarts.github.io/_posts/
git add .
git commit -a -m $1 $2 $3 $4 $5 $6 $7 $8 $9
git push
cd ../superarts.github.io
git add .
git commit -a -m $1 $2 $3 $4 $5 $6 $7 $8 $9
git push