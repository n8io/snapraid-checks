# snapraid-checks

The following commands were tested as `root`. Run at your own risk.

## Clone
1. `git clone git@github.com:n8io/snapraid-checks.git && cd snapraid-checks`

## Set script permissions
1. `chmod a+x ./healthcheck.sh`
1. `chmod a+x ./snapraid-sync.sh`
1. `chmod a+x ./snapraid-scrub.sh`

## Setup Notifications
1. `cat .pushbullet.example > .pushbullet`
1. `nano .pushbullet`
1. Paste in your [pushbullet access token](https://www.pushbullet.com/#settings)
1. Hit `Cmd+X`
1. Test notification: `./send-notifications.sh`

## healthcheck.sh
This script runs a quick `smartctl` healthcheck on each drive it finds based upon a regex in the top of the script. Update as needed. Output goes into `last-healthcheck.log` and `last-healthcheck.err` accordingly. Sends a pushbullet notification on failure.

## snapraid.sh
Runs a `snapraid sync` and saves output into `last-sync.log`. Sends a pushbullet notification on failure.

## snapraid-scrub.sh
Runs a `snapraid scrub` and saves the output into `last-scrub.log`. Sends a pushbullet notification on failure.

## drives (generated)
A file left over from health checks. Helpful if you want to know the capacities and mount points of all your drives.

## TODO
1. Add in depth short and long tests for S.M.A.R.T. monitoring
