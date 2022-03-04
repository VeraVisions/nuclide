
/* both base_player and base_spectator are based off this class */
class
base_client:NSSurfacePropEntity
{
	void(void) base_client;

	virtual void(void) ClientInputFrame;


#ifdef CLIENT
	virtual void(void) UpdateDeathcam;
	virtual float(void) predraw;
#endif
};
