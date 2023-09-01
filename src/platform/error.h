var string g_lastDisconnectReason = "";

bool
Error_ServerDisconnected(void)
{
	string disconnectReason;

	disconnectReason = cvar_string("_cl_disconnectreason");

	/* still empty */
	if (disconnectReason == "") {
		return false;
	}

	/* save to cache */
	g_lastDisconnectReason = disconnectReason;
	cvar_set("_cl_disconnectreason", "");
	return true;
}

string
Error_GetDisconnectReason(void)
{
	return g_lastDisconnectReason;
}