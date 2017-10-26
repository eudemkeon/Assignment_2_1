/* time.c */

/*************************************************
 * EEE3535-01 Fall 2017                          *
 * School of Electrical & Electronic Engineering *
 * Yonsei University, Seoul, South Korea         *
 *************************************************/

#include "types.h"
#include "user.h"

int main(int argc, char *argv[]) {
	int runtime_1 = uptime();
	int rc = fork();
	if(argc < 2) { printf(1, "time <executable>\n"); exit(); }
	
	if(rc<0){
		printf(1,"fork() faild");
		exit();
	}

	else if (rc>0){
   // int pid = 0;
	 int runtime = 0;
    wait();
	 int runtime_2=uptime();
	 runtime = runtime_2 - runtime_1;
    runtime = runtime *10;
	 for(int i = 1; i < argc; i++) { printf(1, "%s ", argv[i]); }
   
	 printf(1, "(pid = %d): ",rc);
    printf(1, "runtime = %ds%dms\n", runtime/1000, runtime-runtime/1000);
    exit();
	}

	else {
		printf(1,"child process\n");
		exec(argv[1],argv+1);
		exit();
	}

}
