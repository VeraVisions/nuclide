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

void
Event_Parse(float type)
{
	entity me = pSeat->m_ePlayer;

	switch (type) {
	case EV_DAMAGE:
		vector vecDmgPos;
		int iDmgTake;
		int iDmgFlags;
		vecDmgPos[0] = readcoord();
		vecDmgPos[1] = readcoord();
		vecDmgPos[2] = readcoord();
		iDmgTake = readint();
		iDmgFlags = readint();
		CSQC_Parse_Damage_New(vecDmgPos, iDmgTake, iDmgFlags);
		break;
	case EV_HITNOTIFY:
		break;
	case EV_INTERMISSION:
		int cam;
		vector pos, ang;

		cam = (int)readbyte();

		if (cam) {
			ang[0] = readfloat();
			ang[1] = readfloat();
			ang[2] = readfloat();

			pos[0] = readcoord();
			pos[1] = readcoord();
			pos[2] = readcoord();
		} else {
			pos = getproperty(VF_ORIGIN);
			ang = getproperty(VF_ANGLES);
		}

		pSeat->m_vecCameraOrigin = pos;
		pSeat->m_vecCameraAngle = ang;
		g_iIntermission = TRUE;
		break;
	case EV_MUSICTRACK:
		Music_ParseTrack();
		break;
	case EV_MUSICLOOP:
		Music_ParseLoop();
		break;
	case EV_SPEAK:
		string msg;
		float pit;
		entity t = findfloat(world, entnum, readentitynum());
		msg = readstring();
		pit = readfloat();
		sound(t, CHAN_VOICE, msg, 1.0, ATTN_NORM, pit);
		break;
	case EV_SENTENCE:
		NSTalkMonster_ParseSentence();
		break;
	case EV_HUDHINT:
		string hint;
		hint = readstring();
		/* TODO: Handle the event properly */
		Chat_Parse(sprintf("Hint: %s", hint));
		break;
	case EV_FADE:
		Fade_Parse();
		break;
	case EV_SPRITE:
		EnvSprite_ParseEvent();
		break;
	case EV_TEXT:
		GameText_Parse();
		break;
	case EV_MESSAGE:
		GameMessage_Parse();
		break;
	case EV_CAMERATRIGGER:
		vector cam_newpos;

		cam_newpos[0] = readcoord();
		cam_newpos[1] = readcoord();
		cam_newpos[2] = readcoord();

		pSeat->m_vecCameraAngle[0] = readcoord();
		pSeat->m_vecCameraAngle[1] = readcoord();
		pSeat->m_vecCameraAngle[2] = readcoord();

		pSeat->m_flCameraTime = time + readfloat();

		/* if the same camera as last-time (hack) is still active,
		   then make sure it becomes inactive... */
		if (pSeat->m_vecCameraOrigin == cam_newpos) {
			pSeat->m_flCameraTime = 0.0f;
		} else {
			pSeat->m_vecCameraOrigin = cam_newpos;
		}
		break;
	case EV_ANGLE:
		vector a;
		a[0] = readfloat();
		a[1] = readfloat();
		a[2] = readfloat();
        g_view.SetCameraAngle(a);
        g_view.SetClientAngle(a);
		break;
	case EV_SURFIMPACT:
		SurfData_Impact_Parse();
		break;
	case EV_DECALGROUP:
		DecalGroups_Receive();
		break;
	case EV_CLEARDECALS:
		CMD_Cleardecals();
		break;
	case EV_SHAKE:
		if (me.classname == "spectator")
			break;
		pSeat->m_flShakeDuration = readfloat();
		pSeat->m_flShakeAmp = readfloat();
		pSeat->m_flShakeFreq = readfloat();
		pSeat->m_flShakeTime = pSeat->m_flShakeDuration;
		break;
	case EV_BREAKMODEL:
		BreakModel_Receive();
		break;
	default:
		error("event not recognized. abort immediately.\n");
	}
}
