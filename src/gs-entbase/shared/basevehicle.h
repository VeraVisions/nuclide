
class CBaseVehicle:CBaseTrigger
{
	int m_iVehicleFlags;
	int m_iMoveButtons;
	vector m_vecMoveValues;

	entity m_eDriver;
	entity m_eDriver_net;

	void(void) CBaseVehicle;
	vector m_vecPlayerPos;

	vector angles_net;
	vector origin_net;
	vector velocity_net;

#ifdef CLIENT
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
	virtual void(float, float) ReadEntity;
	virtual void(void) UpdateView;
#else
	virtual float(entity, float) SendEntity;
#endif

	virtual void(void) PlayerUpdateFlags;
	virtual void(void) PlayerAlign;
	virtual void(base_player) PlayerEnter;
	virtual void(base_player) PlayerLeave;
	virtual void() PlayerInput;
};

enumflags
{
	VEHFL_CHANGED_ORIGIN,
	VEHFL_CHANGED_ANGLES,
	VEHFL_CHANGED_MODELINDEX,
	VEHFL_CHANGED_SOLID,
	VEHFL_CHANGED_MOVETYPE,
	VEHFL_CHANGED_SIZE,
	VEHFL_CHANGED_VELOCITY,
	VEHFL_CHANGED_DRIVER
};
