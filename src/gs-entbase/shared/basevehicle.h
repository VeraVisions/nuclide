
.int m_iVehNum;

class CBaseVehicle:CBaseTrigger
{
	int m_iVehicleFlags;
	int m_iMoveButtons;
	vector m_vecMoveValues;

	entity m_eDriver;

	void(void) CBaseVehicle;
	vector m_vecPlayerPos;

	vector angles_net;
	vector origin_net;
	vector velocity_net;

#ifdef CLIENT
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#endif

	virtual void(void) PlayerUpdateFlags;
	virtual void(void) PlayerAlign;
	virtual void(base_player) PlayerEnter;
	virtual void(base_player) PlayerLeave;
	virtual void() PlayerInput;
}; 
