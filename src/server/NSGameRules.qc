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

var bool autocvar_sv_friendlyFire = false;
var int autocvar_mp_td_dmgToKick = 300i;
var int autocvar_mp_td_dmgToWarn = 200i;

void
NSGameRules::NSGameRules(void)
{
	forceinfokey(world, "teamplay", "0");
	identity = 2;
}

void
NSGameRules::Save(float handle)
{
	SaveInt(handle, "m_iIntermission", m_iIntermission);
	SaveFloat(handle, "m_flIntermissionTime", m_flIntermissionTime);
	SaveFloat(handle, "m_flIntermissionCycle", m_flIntermissionCycle);
}

void
NSGameRules::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_iIntermission":
		m_iIntermission = ReadInt(strValue);
		break;
	case "m_flIntermissionTime":
		m_flIntermissionTime = ReadFloat(strValue);
		break;
	case "m_flIntermissionCycle":
		m_flIntermissionCycle = ReadFloat(strValue);
		break;
	}
}

void
NSGameRules::RestoreComplete(void)
{
	/* mark this as our active game-rule upon restore. */
	g_grMode = this;
}

/* init */
void
NSGameRules::InitPostEnts(void)
{
	//print("Init!\n");
}

/* logic */
void
NSGameRules::FrameStart(void)
{
	//print("StartFrame!\n");
}
bool
NSGameRules::ConsoleCommand(NSClientPlayer pl, string cmd)
{
	return (false);
}
bool
NSGameRules::ClientCommand(NSClient pl, string cmd)
{
	return (false);
}
bool
NSGameRules::ImpulseCommand(NSClient pl, float num)
{
	return (false);
}

/* client */
void
NSGameRules::PlayerConnect(NSClientPlayer pl)
{
	if (Plugin_PlayerConnect(pl) == FALSE)
		bprint(PRINT_HIGH, sprintf("%s^d connected.\n", pl.netname));
}
void
NSGameRules::PlayerDisconnect(NSClientPlayer pl)
{
	bprint(PRINT_HIGH, sprintf("%s^d disconnected.\n", pl.netname));
}

void
NSGameRules::PlayerKill(NSClientPlayer pl)
{
	Damage_Apply(pl, pl, pl.health, 0, DMG_SKIP_ARMOR);
}
void
NSGameRules::PlayerDeath(NSClientPlayer pl)
{
	//print("PlayerDeath!\n");
	pl.Death();
}
void
NSGameRules::PlayerPain(NSClientPlayer pl)
{
	//print("ClientKill!\n");
	pl.Pain();
}
void
NSGameRules::PlayerSpawn(NSClientPlayer pl)
{
	//print("PutClientInServer!\n");
}
void
NSGameRules::PlayerPreFrame(NSClientPlayer pl)
{
	//print("PlayerPreThink!\n");
}
void
NSGameRules::PlayerPostFrame(NSClientPlayer pl)
{
	//print("PlayerPostThink!\n");
}

/* level transitions */
void
NSGameRules::LevelNewParms(void)
{
	//print("LevelNewParms!\n");
}
void
NSGameRules::LevelChangeParms(NSClientPlayer pl)
{
	//print("LevelChangeParms!\n");
}

/* spectator */
/*void
NSGameRules::SpectatorConnect(player pl)
{
	//print("SpectatorConnect!\n");
}
void
NSGameRules::SpectatorDisconnect(player pl)
{
	//print("SpectatorDisconnect!\n");
}
void
NSGameRules::SpectatorThink(player pl)
{
	//print("SpectatorThink!\n");
}*/

int
NSGameRules::MaxItemPerSlot(int slot)
{
	return (-1);
}

void
NSGameRules::IntermissionStart(void)
{
	if (m_iIntermission)
		return;

	m_iIntermission = TRUE;
	m_flIntermissionTime = time + 5.0f;

	for (entity p = world; (p = find(p, ::classname, "player"));) {
		p.health = 0;
		p.modelindex = 0;
	}
}

void
NSGameRules::IntermissionCycle(void)
{
	NSEntity targ;

	if (!m_iIntermission)
		return;

	if (time < m_flIntermissionCycle)
		return;

	/* make the clients aware */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_INTERMISSION);

	m_eIntermissionPoint = (NSEntity)find(m_eIntermissionPoint, ::classname, "info_intermission");

	/* if we have an intermission point, send it to all players. */
	if (m_eIntermissionPoint) {
		targ = (NSEntity)find(world, ::targetname, m_eIntermissionPoint.target);

		if (targ) {
			vector foo;
			foo = vectoangles(targ.origin - m_eIntermissionPoint.origin);
			m_eIntermissionPoint.angles = foo;
		}

		WriteByte(MSG_MULTICAST, 1);
		WriteFloat(MSG_MULTICAST, m_eIntermissionPoint.angles[0]);
		WriteFloat(MSG_MULTICAST, m_eIntermissionPoint.angles[1]);
		WriteFloat(MSG_MULTICAST, m_eIntermissionPoint.angles[2]);
		WriteCoord(MSG_MULTICAST, m_eIntermissionPoint.origin[0]);
		WriteCoord(MSG_MULTICAST, m_eIntermissionPoint.origin[1]);
		WriteCoord(MSG_MULTICAST, m_eIntermissionPoint.origin[2]);

		for (entity pl = world; (pl = find(pl, ::classname, "player"));) {
			setorigin(pl, m_eIntermissionPoint.origin);
		}
	} else {
		WriteByte(MSG_MULTICAST, 0);
	}

	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);

	if (!m_eIntermissionPoint)
		m_flIntermissionCycle = 0.0f;
	else
		m_flIntermissionCycle = time + 5.0f;
}

void
NSGameRules::IntermissionToPlayer(NSClientPlayer targetPlayer)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_INTERMISSION);

	/* we're in an intermission already, so this should be set. */
	if (g_grMode.m_eIntermissionPoint) {
		WriteByte(MSG_MULTICAST, 1);
		WriteFloat(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.angles[0]);
		WriteFloat(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.angles[1]);
		WriteFloat(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.angles[2]);
		WriteCoord(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.origin[0]);
		WriteCoord(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.origin[1]);
		WriteCoord(MSG_MULTICAST, g_grMode.m_eIntermissionPoint.origin[2]);
	} else {
		WriteByte(MSG_MULTICAST, 0);
	}

	msg_entity = targetPlayer;
	multicast([0,0,0], MULTICAST_ONE_R);
}

bool
NSGameRules::InIntermission(void)
{
	return (m_iIntermission) ? true : false;
}

bool
NSGameRules::MonstersSpawn(void)
{
	return (true);
}

/* init */
bool
NSGameRules::IsTeamplay(void)
{
	return (false);
}
bool
NSGameRules::IsMultiplayer(void)
{
	return (false);
}

void
NSGameRules::DamageApply(entity t, entity c, float dmg, int w, damageType_t type)
{
	bool isFriendlyFire = false;

	/* Damage */
	NSSurfacePropEntity eTarget = (NSSurfacePropEntity)t;

	/* sanity check */
	if (t.takedamage == DAMAGE_NO)
		return;

	/* for armor damage */
	float flArmor = 0;
	float flNewDamage = 0;

	/* player god mode */
	if (eTarget.flags & FL_CLIENT && eTarget.flags & FL_GODMODE)
		return;

	/* friendly fire check */
	if (t != c) {
		if (IsTeamplay()) {
			if (t.flags & FL_CLIENT && c.flags & FL_CLIENT) {
				if (t.team == c.team) {
					if (autocvar_sv_friendlyFire == false) {
						return;
					} else {
						isFriendlyFire = true;
					}
				}
			}
		}
	}

	/* already dead, please avoid recursion */
	if (eTarget.GetHealth() <= 0)
		return;

	/* before any calculation is done... */
	g_dmg_iRealDamage = dmg;

	/* only clients have armor */
	if (eTarget.flags & FL_CLIENT) {
		NSClientPlayer tp = (NSClientPlayer)t;

		/* don't allow any damage */
		if (PlayerCanAttack(tp) == false) {
			g_dmg_eAttacker = (NSEntity)c;
			g_dmg_eTarget = (NSEntity)t;
			g_dmg_iDamage = 0;
			g_dmg_iHitBody = 0;
			g_dmg_iFlags = type;
			g_dmg_iWeapon = w;
			return;
		}

		/* skip armor */
		if not (type & DMG_SKIP_ARMOR)
		if (tp.armor && dmg > 0) {

			flNewDamage = dmg * 0.2;
			flArmor = (dmg - flNewDamage) * 0.5;

			if (flArmor > tp.armor) {
				flArmor = tp.armor;
				flArmor *= (1/0.5);
				flNewDamage = dmg - flArmor;
				tp.armor = 0;
			} else {
				tp.armor -= flArmor;
			}
			dmg = flNewDamage;
		}
	}

	dmg = rint(dmg);
	eTarget.SetHealth(eTarget.GetHealth() - dmg);

	/* the globals... */
	g_dmg_eAttacker = (NSEntity)c;
	g_dmg_eTarget = (NSEntity)t;
	g_dmg_iDamage = dmg;
	g_dmg_iHitBody = trace_surface_id;
	g_dmg_iFlags = type;
	g_dmg_iWeapon = w;

	NSLog("%S does %d dmg to %S (body: %d, flags: %i, weapon: %i)",
		c.classname, dmg, t.classname, g_dmg_iHitBody, g_dmg_iFlags, g_dmg_iWeapon);

	/* friendly fire penalty */
	if (isFriendlyFire) {
		int lastDmg = 0i;
		NSClientPlayer plC = (NSClientPlayer)c;
		lastDmg = plC.m_iFriendlyDMG;
		plC.m_iFriendlyDMG += dmg;

		/* kick the client. */
		if (plC.m_iFriendlyDMG >= autocvar_mp_td_dmgToKick) {
			NSLog("Kicking %S due to team damage rules.", plC.netname);
			dropclient(plC);
		} else if (plC.m_iFriendlyDMG >= autocvar_mp_td_dmgToWarn) {
			if (lastDmg < autocvar_mp_td_dmgToKick) {
				// warn player here
				sprint(plC, PRINT_CHAT, "Keep attacking teammates and you will be kicked!\n");
			}
		}

		bprint(PRINT_CHAT, sprintf("%s ^7attacked a teammate.\n", c.netname));
	}

	if (dmg > 0 || flArmor > 0) {
		vector dmg_origin;

		if (c.origin == [0,0,0])
			dmg_origin = g_dmg_eTarget.origin;
		else
			dmg_origin = g_dmg_eAttacker.origin;

		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_DAMAGE);
		WriteCoord(MSG_MULTICAST, dmg_origin[0]);
		WriteCoord(MSG_MULTICAST, dmg_origin[1]);
		WriteCoord(MSG_MULTICAST, dmg_origin[2]);
		WriteInt(MSG_MULTICAST, g_dmg_iRealDamage);
		WriteInt(MSG_MULTICAST, g_dmg_iFlags);
		msg_entity = g_dmg_eTarget;
		multicast([0,0,0], MULTICAST_ONE_R);
	}

	/* only hit notify on clients */
	if ((g_dmg_eTarget.flags & FL_CLIENT) || (g_dmg_eTarget.flags & FL_MONSTER)) {
		/* server-side hitnotify */
		if ((g_dmg_eAttacker.flags & FL_CLIENT) && (g_dmg_eTarget != g_dmg_eAttacker)) {
			WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
			WriteByte(MSG_MULTICAST, EV_HITNOTIFY);
			msg_entity = c;
			multicast([0,0,0], MULTICAST_ONE);
		}
	}

	/* they died */
	if (eTarget.GetHealth() <= 0) {
		if (eTarget.flags & FL_CLIENT) {
			PlayerDeath((player)eTarget);
		} else {
			eTarget.Death();
		}
	} else {
		if (eTarget.flags & FL_CLIENT) {
			PlayerPain((player)eTarget);
		} else {
			eTarget.Pain();
		}
	}
}

/* checks if we can hit an entity at 5 of the same spots */
bool
NSGameRules::DamageCheckTrace(entity t, vector vecHitPos)
{
	/* We're lazy. Who cares */
	if (t.solid == SOLID_BSP)
		return (true);

	traceline(vecHitPos, t.origin, 1, this);
	if (trace_fraction == 1)
		return (true);

	traceline(vecHitPos, t.origin + [15,15,0], 1, this);
	if (trace_fraction == 1)
		return (true);

	traceline(vecHitPos, t.origin + [-15,-15,0], 1, this);
	if (trace_fraction == 1)
		return (true);

	traceline(vecHitPos, t.origin + [-15,15,0], 1, this);
	if (trace_fraction == 1)
		return (true);

	traceline(vecHitPos, t.origin + [15,-15,0], 1, this);
	if (trace_fraction == 1)
		return (true);

	return (false);
}

void
NSGameRules::DamageRadius(vector org, entity attacker, float dmg, float r, bool checkCollision, int w)
{
	float new_dmg;
	float dist;
	float diff;
	vector pos;

	for (entity e = world; (e = nextent(e));) {
		if (e.takedamage == DAMAGE_NO)
			continue;

		pos[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
		pos[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
		pos[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));

		/* don't bother if it's not anywhere near us */
		dist = vlen(org - pos);
		if (dist > r)
			continue;

		/* can we physically hit this thing? */
		if (checkCollision == true)
			if (DamageCheckTrace(e, org) == FALSE)
				continue;

		/* calculate new damage values */
		diff = (r - dist) / r;
		new_dmg = rint(dmg * diff);

		if (diff > 0) {
			g_dmg_vecLocation = trace_endpos;
			DamageApply(e, attacker, new_dmg, w, DMG_EXPLODE);

			/* approximate, feel free to tweak */
			if (e.movetype == MOVETYPE_WALK) {
				makevectors(vectoangles(e.origin - org));
				e.velocity += v_forward * (new_dmg * 5); 
			}
		}
	}
}

void
NSGameRules::IntermissionEnd(void)
{
	if (!m_iIntermission)
		return;

	if (time < m_flIntermissionTime)
		return;

	if (!(input_buttons & INPUT_PRIMARY) && !(input_buttons & INPUT_JUMP))
		return;

	localcmd("nextmap\n");

	m_iIntermission = 0;
	m_flIntermissionTime = -1;
}

bool
NSGameRules::PlayerCanAttack(NSClientPlayer bp)
{
	return true;
}

bool
NSGameRules::PlayerRequestRespawn(NSClientPlayer bp)
{
	return false;
}

void
NSGameRules::ChatMessageAll(NSClient cl, string strMessage)
{
	float edictNum = num_for_edict(cl) - 1;

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_CHAT);
	WriteByte(MSG_MULTICAST, edictNum);
	WriteByte(MSG_MULTICAST, cl.team); 
	WriteString(MSG_MULTICAST, strMessage);
	multicast([0,0,0], MULTICAST_ALL_R);

	/* TODO: don't print on listen games */
	print(Util_ChatFormat(edictNum, 0, strMessage));
	print("\n");
}

void
NSGameRules::ChatMessageTeam(NSClient cl, string strMessage)
{
	float edictNum = num_for_edict(cl) - 1;

	/* their finger probably slipped */
	if (IsTeamplay() == false) {
		ChatMessageAll(cl, strMessage);
		return;
	}

	/* single handedly pick out team members */
	for (entity a = world; (a = find(a, ::classname, "player"));) {
		/* not one of us! */
		if (a.team != cl.team)
			continue;

		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_CHAT_TEAM);
		WriteByte(MSG_MULTICAST, edictNum); 
		WriteByte(MSG_MULTICAST, cl.team); 
		WriteString(MSG_MULTICAST, strMessage);

		msg_entity = a;
		multicast([0,0,0], MULTICAST_ONE_R);
	}

	print(Util_ChatFormat(edictNum, cl.team, strMessage));
	print("\n");
}

string
NSGameRules::Title(void)
{
	return "Default";
}