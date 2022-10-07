#!/bin/bash

cd /export/csweb
find -type f -perm 0666 -exec chmod 0664 {} \;
find -type d -perm 0777 -exec chmod 0775 {} \;
find -type d -perm 2777 -exec chmod 2775 {} \;
find -type d -perm 6777 -exec chmod 2775 {} \;
find -type d -perm 0775 -exec chmod 2775 {} \;
chgrp -R CS-Rights-web *
