#!/bin/bash
#########################################################
# wpperms.sh - This script adjusts the WP Permissions to
#              allow web-based updates and then lock the
#              permissions back down.
#
# mod history
# - 2018.02.22 - Created file
########################################################

WPDIR=""         # Path to your wordpress install
WWWUSR="www-data"                       # Who is the webserver user
LOG="1"                                 # Log to syslog
EXCLUSIONS=""							# Setup exclusions (like for wordfence)

# Set things
CHMOD=$(which chmod)
CHOWN=$(which chown)
FIND=$(which find)
LOGGER=$(which logger)

if [ "$LOG" -eq 1 ]
  then $LOGGER "[WPPERMS] - Script starting"
fi

# Test to confirm that we're root (if not, we can't  do the thing)
if [ "$EUID" -ne 0 ]
  then echo "This script must be run as root"
    if [ "$LOG" -eq 1 ]
      then $LOGGER "[WPPERMS] - Script attemtped to run as non-root user"
    fi
  exit
  else
    if [ "$LOG" -eq 1 ]
      then $LOGGER "[WPPERMS] - Script running as root"
    fi
fi

# Test to confirm the WPDIR exists
if [ -d "$WPDIR" ]
  then
    if [ "$LOG" -eq 1 ]
      then $LOGGER "[WPPERMS] - Confirmed directory $WPDIR exists"
    fi
  else
    echo "The directory $WPDIR does not exist"
    if [ "$LOG" -eq 1 ]
      then $LOGGER "[WPPERMS] - Directory $WPDIR does not exist"
    fi
    exit
fi

# Now, do the thing
case "$1" in
  on)
    if [ "$LOG" -eq 1 ]
      then $LOGGER "[WPPERMS] - Enabling protection"
    fi
    $CHOWN root.$WWWUSR $WPDIR -R
    $FIND $WPDIR -type d -exec chmod 755 {} \; # Make all of the directories readable and executable by everyone
    $FIND $WPDIR -type f -exec chmod 640 {} \; # Make all files readable by the webserver
    
  ;;

  off)
    if [ "$LOG" -eq 1 ]
      then $LOGGER "[WPPERMS] - Disabling protection"
    fi
    $CHOWN $WWWUSR.$WWWUSR $WPDIR -R
  ;;
  *)
    echo $"Usage : $0 (on | off)"
    exit 1
esac
if [ "$LOG" -eq 1 ]
  then $LOGGER "[WPPERMS] - Script Completed"
fi

