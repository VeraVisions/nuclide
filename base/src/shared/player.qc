/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_AMMO1 = PLAYER_CUSTOMFIELDSTART,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED5,
	PLAYER_UNUSED6,
	PLAYER_UNUSED7,
	PLAYER_UNUSED7,
	PLAYER_UNUSED8
};

class player:NSClientPlayer
{
	PREDICTED_INT(mode_tempstate)

#ifdef CLIENT
	virtual void(float,float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
	virtual void(void) UpdateAliveCam;
#else
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#endif
};

#ifdef CLIENT


void Shake_Update(NSClientPlayer);
vector Camera_RunBob(vector);
vector Camera_StrafeRoll(vector);
vector Camera_AddCamBob(vector);
vector Camera_AddLean(vector);
void View_DisableViewmodel(void);
void
player::UpdateAliveCam(void)
{
	vector cam_pos = GetEyePos();

	g_view.SetCameraAngle(view_angles);
	g_view.SetCameraOrigin(cam_pos + Camera_AddCamBob(view_angles) + Camera_AddLean(view_angles));

	if (vehicle) {
		NSVehicle veh = (NSVehicle)vehicle;

		if (veh.UpdateView)
			veh.UpdateView();
	} else if (health) {
		if (autocvar_pm_thirdPerson == TRUE) {
			makevectors(view_angles);
			vector vStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
			vector vEnd = vStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
			traceline(vStart, vEnd, FALSE, this);
			g_view.SetCameraOrigin(trace_endpos + (v_forward * 5));
		}
	}

	Shake_Update(this);
	g_view.AddPunchAngle(punchangle);
}

/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float fl)
{
	NSClientPlayer::ReceiveEntity(new, fl);
	setorigin(this, origin);
}

/*
=================
player::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
player::PredictPreFrame(void)
{
	NSClientPlayer::PredictPreFrame();
}

/*
=================
player::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
player::PredictPostFrame(void)
{
	NSClientPlayer::PredictPostFrame();
}

#else
void
player::EvaluateEntity(void)
{
	NSClientPlayer::EvaluateEntity();
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float fChanged)
{
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	fChanged = OptimiseChangedFlags(ePEnt, fChanged);

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, fChanged);

	/* the generic client attributes */
	NSClientPlayer::SendEntity(ePEnt, fChanged);
	return (1);
}
#endif
