# MAD - Make ADvanced (not really yet)
MAD is a build system that repeats Make but tries to be more obvious in syntax 
and a bit extended.   
Was started as Perl probe project.   
## Example 
Example for C.    
`MADFile`:
```
recipe debug {
    # Defining variable: name must be uppercase, then just 
    # list all contents by whitespaces
    INPUT = file.c helper.c last.c 
    OUTPUT = program
    CC = gcc
    # CMD command runs some command 
    # use .NAME syntax to expand variable
    CMD .CC .INPUT -o .OUTPUT
} end;
# For more advanced (or not) example, see MADFile in repo
```
Run it:
```bash
perl mad.pl debug
```
Or, using shebang:
```bash
./mad.pl 
```
You may also:
```bash 
# Check recipes list 
mad.pl list 
# Check help (comment) about the recipe 
mad.pl recipe help 
```
