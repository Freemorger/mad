# MAD - Make ADvanced (not really yet)
MAD is a build system that repeats Make but tries to be more obvious in syntax 
and a bit extended.   
Was started as Perl probe project.   
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
