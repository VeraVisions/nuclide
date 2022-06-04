
float
Client_IsSpectator(NSClient cl)
{
	if (cl.IsRealSpectator() || cl.IsFakeSpectator())
		return true;

	return false;
}

float
Client_IsRealSpectator(NSClient cl)
{
	return cl.IsRealSpectator();
}

float
Client_IsFakeSpectator(NSClient cl)
{
	return cl.IsFakeSpectator();
}

float
Client_IsDead(NSClient cl)
{
	return cl.IsDead();
}

float
Client_IsPlayer(NSClient cl)
{
	return cl.IsPlayer();
}

/*
=================
Util_GetKeyString
=================
*/
string
Util_GetKeyString(string strBind)
{
	float flBindKey = tokenize(findkeysforcommand(strBind));
	string strBindTx = "";
	float j, k;
	
	for (j = 0; j < flBindKey; ++j) {
		k = stof(argv(j));

		if (k != -1) {
			if (strBindTx != "")
				strBindTx = strcat(strBindTx, ", ");

			strBindTx = strcat(strBindTx, keynumtostring(k));
		}
	}

	if (!strBindTx)
		strBindTx = "UNBOUND";

	return strtoupper(strBindTx);
}
