/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

var bool autocvar_vehicle_developer = false;
void
_NSVehicle_Log(string className, string functionName, float edictNum, string warnMessage)
{
	if (autocvar_g_developerTimestamps)
		printf("^9%f ^2%s (%d) ^7: %s\n", time, functionName, edictNum, warnMessage);
	else
		printf("^2%s (%d) ^7: %s\n", functionName, edictNum, warnMessage);
}
#define NSVehicle_Log(...) if (autocvar_vehicle_developer == true) _NSVehicle_Log(classname, __FUNC__, num_for_edict(this), sprintf(__VA_ARGS__))

/** This entity class represents vehicles that are predicted across the network. */
class NSVehicle:NSSurfacePropEntity
{
private:
	int m_iVehicleFlags;
	int m_iMoveButtons;
	vector m_vecMoveValues;
	NSEntity m_eDriver;
	NSEntity m_eDriver_net;
	NSEntity m_eDriverLast;
	vector m_vecPlayerPos;
	vector m_vecExitPos;

	/* FIXME: Aren't those already defined in parent classes? */
	PREDICTED_VECTOR_N(angles)
	PREDICTED_VECTOR_N(origin)
	PREDICTED_VECTOR_N(velocity)

#ifdef CLIENT
	PREDICTED_FLOAT(driver_entnum)
#endif

public:
	void NSVehicle(void);

#ifdef CLIENT
	virtual void DriverRelink(void);
	virtual bool IsLocalDriver(void);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void ReceiveEntity(float,float);
	virtual void UpdateView(void);
	virtual bool HideViewWeapon(void);
	virtual bool HideCrosshair(void);
	virtual bool HidePlayermodel(void);
#endif

#ifdef SERVER
	nonvirtual vector GetExitPos(void);
	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
	virtual void Save(float);
	virtual void Restore(string,string);
#endif

	nonvirtual entity GetDriver(void);
	virtual void PlayerUpdateFlags(void);
	virtual void PlayerAlign(void);
	virtual void PlayerEnter(NSClientPlayer);
	virtual void PlayerLeave(NSClientPlayer);
	virtual void PlayerInput(void);
	virtual float DriverAnimation(void);
	
	virtual bool CanDriverCrouch(void);
	virtual bool PreventPlayerMovement(void);
	virtual bool PreventPlayerFire(void);
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

enumflags
{
	VHF_FROZEN,
	VHF_NOATTACK
};
