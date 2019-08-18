
var int g_plugins_enabled;
var int autocvar_sv_plugins = 1;

void Plugin_Init(void)
{	
	if (autocvar_sv_plugins) {
		print("Initializing plugins...\n");
		g_plugins_enabled = 1;
	} else {
		print("Initializing plugins...\n");
		g_plugins_enabled = 0;
	}
}

/*
=================
Plugin_RunClientCommand

Funtion that can interrupt client commands before physics are run
=================
*/
int Plugin_RunClientCommand(void)
{
	int(void) vFunc = externvalue(-2, "FMX_RunClientCommand");

	if (vFunc || g_plugins_enabled == 0) {
		return vFunc();
	}

	return FALSE;
}

/*
=================
Plugin_ParseClientCommand

Intercepts 'cmd' calls. We use it to intercept
chat messages and handle distribution ourselves.
=================
*/
int Plugin_ParseClientCommand(string msg)
{
	int(string msg) vFunc = externvalue(-2, "FMX_ParseClientCommand");

	if (vFunc || g_plugins_enabled == 0) {
		return vFunc(msg);
	}

	return FALSE;
}
