
hostprogs-y	:= genksyms
always		:= $(hostprogs-y)

genksyms-objs	:= genksyms.o parse.tab.o lex.lex.o

# -I needed for generated C source (shipped source)
HOSTCFLAGS_parse.tab.o := -I$(src)
<<<<<<< HEAD
HOSTCFLAGS_lex.lex.o := -I$(src)
=======
>>>>>>> 6b19e7e49e6d... genksyms: drop -Wno-uninitialized from HOSTCFLAGS_parse.tab.o

# dependencies on generated files need to be listed explicitly
$(obj)/lex.lex.o: $(obj)/keywords.hash.c $(obj)/parse.tab.h

clean-files	:= keywords.hash.c lex.lex.c parse.tab.c parse.tab.h
