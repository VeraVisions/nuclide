void
base_client::OnRemoveEntity(void)
{
	XR_Shutdown(this);
}

void
base_client::ClientInput(void)
{
}

void
base_client::PreFrame(void)
{
}

void
base_client::PostFrame(void)
{
}

bool
base_client::IsFakeSpectator(void)
{
	return (false);
}

bool
base_client::IsRealSpectator(void)
{
	return (false);
}

bool
base_client::IsDead(void)
{
	return (false);
}

bool
base_client::IsPlayer(void)
{
	return (false);
}

#ifdef CLIENT
void
base_client::ClientInputFrame(void)
{
}

void
base_client::UpdateDeathcam(void)
{
	/* death cam */
	view_angles[2] = 45.0f;
	setproperty(VF_ORIGIN, pSeat->m_vecPredictedOrigin);
	setproperty(VF_CL_VIEWANGLES, view_angles);
	setproperty(VF_ANGLES, view_angles);
}

float
base_client::predraw(void)
{
	return (PREDRAW_NEXT);
}
#endif

void
base_client::base_client(void)
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
