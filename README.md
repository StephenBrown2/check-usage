check-usage
===========

A Shell script to walk a directory tree and inform the user of large folders taking up space

Usage
-----

Running the command by itself, for example: ./check-usage.sh, will output a brief usage message
and scan the current directory for any folders bigger than a gigabyte. The -p pattern argument
will match the entire output of 'du', so by default it looks for a 'G', or multi-gigabyte folders.
