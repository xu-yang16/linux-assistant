#!/bin/bash

systray=$(hostname -I | awk '{print $1}')

echo "$systray" # system-indidicator will put echo string into systray for us.

exit 0