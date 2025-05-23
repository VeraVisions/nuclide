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

var bool autocvar_cg_damageShake = false;

void
EV_Damage(void)
{
	vector vecDmgPos;
	int iDmgTake;
	int iDmgFlags;
	vecDmgPos[0] = readcoord();
	vecDmgPos[1] = readcoord();
	vecDmgPos[2] = readcoord();
	iDmgTake = readint();
	iDmgFlags = readint();
	CSQC_Parse_Damage_New(vecDmgPos, iDmgTake, iDmgFlags);

	if (autocvar_cg_damageShake) {
		pSeat->m_flShakeDuration += 1.25f;
		pSeat->m_flShakeAmp += iDmgTake / 16;
		pSeat->m_flShakeFreq += 0.1;
		pSeat->m_flShakeTime += pSeat->m_flShakeDuration;
	}
}

void
EV_Intermission(void)
{
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
}

void
EV_Speak(void)
{
	string msg;
	float pit;
	entity t = findfloat(world, entnum, readentitynum());
	msg = readstring();
	pit = readfloat();
	sound(t, CHAN_VOICE, msg, 1.0, ATTN_NORM, pit);
}

void
EV_HUDHint(void)
{
	string hint;
	hint = readstring();
	/* TODO: Handle the event properly */
	Chat_Parse(sprintf("Hint: %s", hint));
}

void
EV_CameraTrigger(void)
{
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
}

void
EV_Angle(void)
{
	vector a;
	a[0] = readfloat();
	a[1] = readfloat();
	a[2] = readfloat();
	g_view.SetCameraAngle(a);
	g_view.SetClientAngle(a);
}

void
EV_Shake(void)
{
	entity me = pSeat->m_ePlayer;
	float duration;
	float amplitude;
	float frequency;

	duration = readfloat();
	amplitude = readfloat();
	frequency = readfloat();

	if (me.classname == "spectator")
			return;

	pSeat->m_flShakeDuration = duration;
	pSeat->m_flShakeAmp = amplitude;
	pSeat->m_flShakeFreq = frequency;
	pSeat->m_flShakeTime = pSeat->m_flShakeDuration;
}

void
EV_TraceDebug(void)
{
	static float EV_TraceDebug_Draw(void) {
		R_BeginPolygon("", 0, 0);
		R_PolygonVertex(self.origin, [0,1], [0,1,0], 1.0f);
		R_PolygonVertex(self.angles, [1,1], [1,0,0], 1.0f);
		R_EndPolygon();
		return PREDRAW_NEXT;
	}
	static void EV_TraceDebug_Destroy(void) {
		remove(self);
	}

	vector startOrg, endOrg;
	entity traceRep;

	startOrg[0] = readcoord();
	startOrg[1] = readcoord();
	startOrg[2] = readcoord();

	endOrg[0] = readcoord();
	endOrg[1] = readcoord();
	endOrg[2] = readcoord();

	traceRep = spawn();
	traceRep.predraw = EV_TraceDebug_Draw;
	traceRep.drawmask = MASK_ENGINE;
	traceRep.think = EV_TraceDebug_Destroy;
	traceRep.nextthink = time + 4.0f;

	traceRep.origin = startOrg;
	traceRep.angles = endOrg;
}

void
EV_Achievement(void)
{
	string eventName = readstring();
	ncLog("EV_Achievement: %S",  eventName);
}

void
EV_EntityEvent(void)
{
	ncEntity targetEntity = (ncEntity)findfloat(world, ::entnum, readentitynum());
	float eventType = readfloat();

	if (targetEntity)
		targetEntity.ReceiveEvent(eventType);
}

void
EV_Pickup(void)
{
	int entityDefID = readint();
	string itemClass = EntityDef_NameFromNetID(entityDefID);
	ncLog("Player picked up item %S", itemClass);

	if (EntityDef_GetKeyValue(itemClass, "pickupFlash") == "1") {
		localcmd("bf\n");
	}

	if (pSeat->m_ePlayer && ((ncActor)pSeat->m_ePlayer).m_activeWeapon) {
		((ncActor)pSeat->m_ePlayer).SortWeaponChain();
	}

	HUD_PickedUpItem(itemClass);
}

void
EV_Obituary(void)
{
	string targetName = readstring();
	string attackerName = readstring();
	string weaponDef = readstring();
	string meansOfDeath = readstring();

	ncLog("Obituary:");
	ncLog("\ttargetName: %S", targetName);
	ncLog("\tattackerName: %S", attackerName);
	ncLog("\tweaponDef: %S", weaponDef);
	ncLog("\tmeansOfDeath: %S", meansOfDeath);
	ncLog("End");

	HUD_Obituary(targetName, attackerName, weaponDef, meansOfDeath);
}

void
Event_Parse(float type)
{
	switch (type) {
	case EV_OBITUARY:
		EV_Obituary();
		break;
	case EV_PICKUP:
		EV_Pickup();
		break;
	case EV_DAMAGE:
		EV_Damage();
		break;
	case EV_HITNOTIFY:
		break;
	case EV_INTERMISSION:
		EV_Intermission();
		break;
	case EV_MUSICTRACK:
		Music_ParseTrack();
		break;
	case EV_MUSICLOOP:
		Music_ParseLoop();
		break;
	case EV_SPEAK:
		EV_Speak();
		break;
	case EV_SENTENCE:
		ncTalkMonster_ParseSentence();
		break;
	case EV_HUDHINT:
		EV_HUDHint();
		break;
	case EV_FADE:
		Fade_Parse();
		break;
	case EV_SPRITE:
		EnvSprite_ParseEvent();
		break;
	case EV_TEXT:
		GameText_ParseString();
		break;
	case EV_TEXT_STRING:
		GameText_ParseString();
		break;
	case EV_MESSAGE:
		GameMessage_Parse();
		break;
	case EV_CAMERATRIGGER:
		EV_CameraTrigger();
		break;
	case EV_ANGLE:
		EV_Angle();
		break;
	case EV_SURFIMPACT:
		SurfData_Impact_Parse();
		break;
	case EV_SURFIMPACTID:
		SurfData_ImpactID_Parse();
		break;
	case EV_DECALGROUP:
		DecalGroups_Receive();
		break;
	case EV_CLEARDECALS:
		CMD_Cleardecals();
		break;
	case EV_SHAKE:
		EV_Shake();
		break;
	case EV_BREAKMODELDATA:
		BreakModel_ReceiveClientData();
		break;
	case EV_BREAKMODEL:
		BreakModel_Receive();
		break;
	case EV_BEAMCYLINDER:
		EV_BeamCylinder_Parse();
		break;
	case EV_TRACEDEBUG:
		EV_TraceDebug();
		break;
	case EV_ACHIEVEMENT:
		EV_Achievement();
		break;
	case EV_ENTITYEVENT:
		EV_EntityEvent();
		break;
	case EV_CHAT:
		float fSender = readbyte();
		float fTeam = readbyte();
		string sMessage = readstring();

		CSQC_Parse_Print(Util_ChatFormat(fSender, 0, sMessage), PRINT_CHAT);
		break;
	case EV_CHAT_TEAM:
		float fSender2 = readbyte();
		float fTeam2 = readbyte();
		string sMessage2 = readstring();

		CSQC_Parse_Print(Util_ChatFormat(fSender2, fTeam2, sMessage2), PRINT_CHAT);
		break;
	default:
		error(sprintf("event id %d not recognized. abort immediately.\n", type));
	}
}
