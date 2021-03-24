enumflags
{
	SPECFL_ORIGIN,
	SPECFL_VELOCITY,
	SPECFL_TARGET,
	SPECFL_MODE,
	SPECFL_FLAGS
};

enum
{
	SPECMODE_FREE,
	SPECMODE_THIRDPERSON,
	SPECMODE_FIRSTPERSON,
	SPECMODE_OVERVIEW
};

#ifdef SERVER
class spectator:CBaseEntity
#else
class spectator
#endif
{
	vector origin_net;
	vector velocity_net;
	float spec_ent; float spec_ent_net;
	float spec_mode; float spec_mode_net;
	float spec_flags; float spec_flags_net;

	int sequence;

	void(void) spectator;

	virtual void(void) playernext;
	virtual void(void) playerprevious;
	virtual void(void) modeswitch;

	virtual void(void) PreFrame;
	virtual void(void) PostFrame;

	virtual void(void) Input;

	virtual void(void) WarpToTarget;

#ifdef SERVER
	virtual float(entity, float) SendEntity;
	virtual void(void) RunClientCommand;
#else
	virtual void(float) ReceiveEntity;
	virtual float(void) predraw;
#endif
}; 
