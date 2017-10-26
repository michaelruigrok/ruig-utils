### vimdo: execute a vim command for each given file
```
Usage: vimdo [COMMAND FILENAME...]  
   or: vimdo [replace SEARCH REPLACEMENT FILENAME...]
```

This program executes a vim command for each of the given files.
'Command' may be a string of multiple vim commands separated by '|'.

NOTE/WARNING: make sure you end all substitutions with '/e', otherwise
it will stop at the first file that misses a match.
You can always use the 'replace' argument instead.

---

### subgrep: Search for a pattern between up to 2 other patterns or lines, inclusive.
```
Usage: subgrep [BEGINNING END MATCH]  
   or: subgrep [OPTION DELIM MATCH]
```

Matches between a beginning and end line (specified by either line number or
matching pattern) are printed out.

Any matches between the first occurrence of BEGINNING and the first occurence
of END will be matched, but another occurence of BEGINNING will search again.
DELIM is either the same as BEGINNING or END, depending on what OPTION is given
