#!/usr/bin/env python

# script use to handle multiuser access to a sing git repo.
# - servers have an ssh key and are able to access their own config repo
# - "masters" can access all repos

# heavy inspiration from
# - https://moocode.com/posts/6-code-your-own-multi-user-private-git-server-in-5-minutes

import sys, os
from subprocess import call

# user and permissions are passed from authorized_keys

# handle cmd line
user = sys.argv[1]
permissions = sys.argv[2]
command = os.environ['SSH_ORIGINAL_COMMAND']

if not user or not permissions or not command:
    sys.exit( 1 )

# check the supplied command contains a valid git action 
valid_actions = ['git-receive-pack', 'git-upload-pack']
action, repo = command.split(' ')
repo = repo.strip("'").split('.')[0]

if not action in valid_actions:
    print >>sys.stderr, "bad action:", action
    sys.exit( 2 ) 

# check the permissions for this user

if not 'r' in permissions:
    print >>sys.stderr, "read denied for %s"%user
    sys.exit( 3 ) 

if action == 'git-receive-pack' and not 'w' in permissions:
    print >>sys.stderr, "write denied for %s"%user
    sys.exit( 4 ) 

if user != 'master' and user != repo:
    print >>sys.stderr, "user %s is not allowed to access repo %s"%(user, repo)
    sys.exit( 5 )

print >>sys.stderr, "user %s authorized to access repo %s\n"%(user, repo)

# user made a valid request so handing over to git-shell
params = ['git', 'shell', '-c', "%s '%s.git'"%(action, repo)]
call( params )



