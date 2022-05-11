/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

class NSVehicle:NSSurfacePropEntity
{
	int m_iVehicleFlags;
	int m_iMoveButtons;
	vector m_vecMoveValues;

	entity m_eDriver;
	entity m_eDriver_net;

	entity m_eDriverLast;

	void(void) NSVehicle;

	vector m_vecPlayerPos;

	vector angles_net;
	vector origin_net;
	vector velocity_net;
	vector m_vecExitPos;

#ifdef CLIENT
	PREDICTED_FLOAT(driver_entnum);

	virtual void(void) DriverRelink;
	virtual bool(void) IsLocalDriver;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
	virtual void(float, float) ReceiveEntity;
	virtual void(void) UpdateView;
	virtual bool(void) HideViewWeapon;
	virtual bool(void) HideCrosshair;
	virtual bool(void) HidePlayermodel;
#else
	virtual vector(void) GetExitPos;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#endif

	virtual entity(void) GetDriver;
	virtual void(void) PlayerUpdateFlags;
	virtual void(void) PlayerAlign;
	virtual void(NSClientPlayer) PlayerEnter;
	virtual void(NSClientPlayer) PlayerLeave;
	virtual void() PlayerInput;
	virtual float(void) DriverAnimation;

	virtual bool(void) CanDriverCrouch;
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

#ifdef CLIENT
void basevehicle_readentity(float isnew);
#endif
