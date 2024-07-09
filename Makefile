all: raprec raprun
raprec: raprec.c
	gcc raprec.c -o raprec -Wall -I/usr/include/mariadb -L/usr/lib/mariadb -lmariadb -lm
raprun: raprun.c
	gcc raprun.c -o raprun -Wall -I/usr/include/mariadb -L/usr/lib/mariadb -lmariadb -lbluetooth

install:
	cp raprec /usr/bin
	cp raprun /usr/bin
	chmod u+s /usr/bin/raprun
clean:
	-rm raprec raprun

