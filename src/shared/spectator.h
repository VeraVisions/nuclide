typedef enumflags
{
	SPECFL_ORIGIN,
	SPECFL_VELOCITY,
	SPECFL_TARGET,
	SPECFL_MODE,
	SPECFL_FLAGS
} spectatorFlags_t;

typedef enum
{
	SPECMODE_FREE,
	SPECMODE_THIRDPERSON,
	SPECMODE_FIRSTPERSON,
	SPECMODE_OVERVIEW
} spectatorMode_t;

typedef enumflags
{
	SPECFLAG_BUTTON_RELEASED,
};

class spectator:base_client
{
	PREDICTED_FLOAT(spec_ent);
	PREDICTED_FLOAT(spec_flags);
	spectatorMode_t spec_mode; spectatorMode_t spec_mode_net;

	vector spec_org;

	int sequence;

	void(void) spectator;

	virtual void(void) ClientInput;

	virtual void(void) InputNext;
	virtual void(void) InputPrevious;
	virtual void(void) InputMode;

	virtual void(void) WarpToTarget;

	virtual void(void) PreFrame;
	virtual void(void) PostFrame;
	virtual void(void) SpectatorTrackPlayer;

#ifdef SERVER
	virtual void(void) EvaluateEntity;
	virtual float(entity, vector) SendEntity;
	virtual void(void) RunClientCommand;
#else
	virtual void(void) ClientInputFrame;
	virtual void(float,float) ReceiveEntity;
	virtual float(void) predraw;
#endif
};

#ifdef CLIENT
void Spectator_ReadEntity(float new);
#endif
