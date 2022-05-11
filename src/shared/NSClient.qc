void
NSClient::OnRemoveEntity(void)
{
	XR_Shutdown(this);
}

void
NSClient::ClientInput(void)
{
}

void
NSClient::PreFrame(void)
{
}

void
NSClient::PostFrame(void)
{
}

bool
NSClient::IsFakeSpectator(void)
{
	return (false);
}

bool
NSClient::IsRealSpectator(void)
{
	return (false);
}

bool
NSClient::IsDead(void)
{
	return (false);
}

bool
NSClient::IsPlayer(void)
{
	return (false);
}

#ifdef CLIENT
void
NSClient::ClientInputFrame(void)
{
}

void
NSClient::UpdateDeathcam(void)
{
	/* death cam */
	view_angles[2] = 45.0f;
	setproperty(VF_ORIGIN, pSeat->m_vecPredictedOrigin);
	setproperty(VF_CL_VIEWANGLES, view_angles);
	setproperty(VF_ANGLES, view_angles);
}

float
NSClient::predraw(void)
{
	return (PREDRAW_NEXT);
}
#endif

void
NSClient::NSClient(void)
{
	XR_Init(this);
}


float
Client_InIntermission(void)
{
#ifdef CLIENT
	return g_iIntermission;
#else
	return (float)g_grMode.InIntermission();
#endif
}
