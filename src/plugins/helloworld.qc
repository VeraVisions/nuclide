#pragma target fte_5768
#pragma PROGS_DAT  "../../base/plugins/helloworld.dat"
#include "../server/api.h"

var bool g_firstLoaded = false;

void
Plug_Load(void)
{
	if (g_firstLoaded == false) {
		printf("Hello world!\n");
		g_firstLoaded = true;
	} else {
		printf("Hello again!\n");
	}
}

void
Plug_Shutdown(void)
{
	printf("See you again!\n");
}
