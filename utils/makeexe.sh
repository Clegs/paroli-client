#!/bin/bash

# Modifies the output of the coffee compiler and makes sure
# that the right execute flags are set.

header='#!/usr/bin/env node'

for file in "$@"; do
	firstLine=`head -1 $file`
	
	if [ "$firstLine" != "$header" ]; then
		sed -i "1i#!/usr/bin/env node\n" $file
		chmod +x $file
	fi
done

