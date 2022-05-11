
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
