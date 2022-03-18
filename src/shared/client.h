
/* both base_player and base_spectator are based off this class */
class
base_client:NSSurfacePropEntity
{
	vector origin_net;
	vector velocity_net;

	void(void) base_client;

	/* final input handling of the client */
	virtual void(void) ClientInput;

	virtual void(void) PreFrame;
	virtual void(void) PostFrame;

	virtual int(void) IsFakeSpectator;


#ifdef CLIENT
	/* gives the chance to override input variables before networking */
	virtual void(void) ClientInputFrame;

	/* our camera when we're dead */
	virtual void(void) UpdateDeathcam;

	/* run every frame before renderscene() */
	virtual float(void) predraw;
#endif
};
