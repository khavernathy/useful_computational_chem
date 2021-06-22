#!/bin/bash

#git filter-branch --index-filter 'git rm -r --cached --ignore-unmatch examples/*.cphd examples/*.mat examples/*.nitf' --prune-empty
git filter-branch --index-filter 'git rm -r --cached --ignore-unmatch sarpy six-library RITSAR' --prune-empty
git update-ref $(git for-each-ref --format='delete %(refname)' refs/original)
git reflog expire --expire=now --all
git gc --aggressive --prune=now

git commit -m "wipe old packfile garbage"
git push -f
