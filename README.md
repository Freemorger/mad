# MAD - Make ADvanced (not really yet)
MAD is a build system that repeats Make but tries to be more obvious in syntax 
and a bit extended.
## Example 
Example for C.    
`MADFile`:
```
INPUT file.c helper.c last.c
OUTPUT program
CC gcc
CMD .CC .INPUT -o .OUTPUT
```
Run it:
```bash
perl mad.pl 
```
Or, using shebang:
```bash
./mad.pl 
```
