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

int
base_client::IsFakeSpectator(void)
{
	return (FALSE);
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

}
