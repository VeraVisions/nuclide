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
		setproperty(VF_CL_VIEWANGLES, a);
		setproperty(VF_ANGLES, a);
		break;
	case EV_SHAKE:
		if (me.classname == "spectator")
			break;
		pSeat->m_flShakeDuration = readfloat();
		pSeat->m_flShakeAmp = readfloat();
		pSeat->m_flShakeFreq = readfloat();
		pSeat->m_flShakeTime = pSeat->m_flShakeDuration;
		break;
	default:
		error("event not recognized. abort immediately.\n");
	}
}
