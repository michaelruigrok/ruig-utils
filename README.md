###vimdo: execute a vim command for each given file
Usage: vimdo [COMMAND FILENAME...]  
   or: vimdo [replace SEARCH REPLACEMENT FILENAME...]

This program executes a vim command for each of the given files.
'Command' may be a string of multiple vim commands separated by '|'.

NOTE/WARNING: make sure you end all substitutions with '/e', otherwise
it will stop at the first file that misses a match.
You can always use the 'replace' argument instead.
