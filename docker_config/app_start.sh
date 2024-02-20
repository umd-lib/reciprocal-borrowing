#!/usr/bin/env bash

# Start shibd
echo --- Starting Shibboleth SP ---
/usr/sbin/shibd start

# Start Apache
# Use "exec" to start Apache so that the application will receive the SIGTERM
# sent to the root process (PID 1), giving the application a chance to
# gracefully shutdown.
echo --- Starting Apache ---
exec apache2ctl -D FOREGROUND
echo --- Done. Exiting ---
