#include <sys/types.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define	S_LEFT	1
#define	S_RIGHT	2

void
show_val(int val)
{
	int i;

	for (i = 31; i >= 0; i--)
		printf("_");
	printf("\n");
	for (i = 31; i >= 0; i--) {
		if (val & (1 << i)) {
			printf("1");
		} else {
			printf("0");
		}
	}
	printf("\n");
}

int
main(int argc, char **argv)
{
	uint32_t	state;
	uint32_t	val;

	(void)argc;
	(void)argv;

	setbuf(stdout, NULL);

	// initial
	state = S_RIGHT;
	val = 1 << 31;

	// always
	for (;;) {
		show_val(val);
		if (state == S_RIGHT) {
			if (val == 0x1) {
				state = S_LEFT;
			} else {
				val = val >> 1;
			}
		} else {
			if (val == 0x80000000) {
				state = S_RIGHT;
			} else {
				val = val << 1;
			}
		}
		usleep(1e6/4);
	}

	exit(EXIT_SUCCESS);
}
