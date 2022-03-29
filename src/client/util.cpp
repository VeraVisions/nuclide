
float
Client_IsSpectator(base_client cl)
{
	return (getplayerkeyfloat(cl.entnum - 1, "*spec") > 0) ? TRUE : FALSE;
}

float
Client_IsRealSpectator(base_client cl)
{
	return (cl.classname == "spectator") ? TRUE : FALSE;
}

float
Client_IsFakeSpectator(base_client cl)
{
	return (getplayerkeyvalue(cl.entnum - 1, "*spec") == "2") ? TRUE : FALSE;
}

float
Client_IsDead(base_client cl)
{
	if (Client_IsSpectator(cl) == TRUE)
		return FALSE;
	else
		return (getplayerkeyvalue(cl.entnum - 1, "*dead") == "1") ? TRUE : FALSE;
}

float
Client_IsPlayer(base_client cl)
{
	return (cl.classname == "player") ? TRUE : FALSE;
}