#!/usr/bin/env python

# heavy inspiration from
# - https://moocode.com/posts/6-code-your-own-multi-user-private-git-server-in-5-minutes

import sys, os
from subprocess import call

# user and permissions are passed from authorized_keys



# handle cmd line
user = sys.argv[1]
print >>sys.stderr, "-", user

permissions = sys.argv[2]
print >>sys.stderr, "-", permissions

command = os.environ['SSH_ORIGINAL_COMMAND']
print >>sys.stderr, "-", command

if not user or not permissions or not command:
    sys.exit( 1 )

# check the supplied command contains a valid git action 
valid_actions = ['git-receive-pack', 'git-upload-pack']
action = command.split(' ')[0]

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

print >>sys.stderr, "user %s authorized\n"%user

# user made a valid request so handing over to git-shell
call( ['git', 'shell', '-c', command] )



