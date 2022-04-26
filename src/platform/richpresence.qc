/* extremely primitive rich presence stuff that'll be extended later down the line or something */

#define RICHPRESENCE_KEYS 2

typedef enum
{
	RICHPRES_STATUS,
	RICHPRES_CONNECT
} richpresence_e;

string g_richpres[RICHPRESENCE_KEYS];
var bool g_richpresence_set = false;

void
RichPresence_Set(string strKey, string strValue)
{
	switch (strKey) {
	/* just fluff */
	case "status":
		g_richpres[RICHPRES_STATUS] = strValue;
		//print(sprintf("^2Client Rich Presence: Status changed to '%s'\n", strValue));
		break;
	/* a command line that'll allow others to join our game */
	case "connect":
		g_richpres[RICHPRES_CONNECT] = strValue;
		//print(sprintf("^2Client Rich Presence: Connection parm changed to '%s'\n", strValue));
		break;
	}

	g_richpresence_set = true;
};

void
RichPresence_Clear(void)
{
	for (int i = 0; i < RICHPRESENCE_KEYS; i++)
		g_richpres[i] = "";

	g_richpresence_set = false;
}

void
RichPresence_DumpInfo(void)
{
	for (int i = 0; i < RICHPRESENCE_KEYS; i++)
		print(sprintf("[%i] %s\n", i, g_richpres[i]));
}

bool
RichPresence_WasSet(void)
{
	return g_richpresence_set;
}