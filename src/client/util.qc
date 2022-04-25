
float
Client_IsSpectator(base_client cl)
{
	if (cl.IsRealSpectator() || cl.IsFakeSpectator())
		return true;

	return false;
}

float
Client_IsRealSpectator(base_client cl)
{
	return cl.IsRealSpectator();
}

float
Client_IsFakeSpectator(base_client cl)
{
	return cl.IsFakeSpectator();
}

float
Client_IsDead(base_client cl)
{
	return cl.IsDead();
}

float
Client_IsPlayer(base_client cl)
{
	return cl.IsPlayer();
}