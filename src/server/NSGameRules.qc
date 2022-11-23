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

/* client */
void
NSGameRules::PlayerConnect(NSClientPlayer pl)
{
	if (Plugin_PlayerConnect(pl) == FALSE)
		bprint(PRINT_HIGH, sprintf("%s connected\n", pl.netname));
}
void
NSGameRules::PlayerDisconnect(NSClientPlayer pl)
{
	bprint(PRINT_HIGH, sprintf("%s disconnected\n", pl.netname));

	/* make the client 'unusable' */
	pl.SetSolid(SOLID_NOT);
	pl.SetMovetype(MOVETYPE_NONE);
	pl.SetModelindex(0);
	pl.SetHealth(0);
	pl.SetTakedamage(DAMAGE_NO);
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
	static NSEntity cam;
	NSEntity targ;

	if (!m_iIntermission)
		return;

	if (time < m_flIntermissionCycle)
		return;

	/* make the clients aware */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_INTERMISSION);

	cam = (NSEntity)find(cam, ::classname, "info_intermission");

	if (cam) {
		targ = (NSEntity)find(world, ::targetname, cam.target);

		if (targ) {
			vector foo;
			foo = vectoangles(targ.origin - cam.origin);

			WriteByte(MSG_MULTICAST, 1);
			WriteFloat(MSG_MULTICAST, foo[0]);
			WriteFloat(MSG_MULTICAST, foo[1]);
			WriteFloat(MSG_MULTICAST, foo[2]);
			WriteCoord(MSG_MULTICAST, cam.origin[0]);
			WriteCoord(MSG_MULTICAST, cam.origin[1]);
			WriteCoord(MSG_MULTICAST, cam.origin[2]);
		}

		for (entity pl = world; (pl = find(pl, ::classname, "player"));) {
			setorigin(pl, cam.origin);
		}
	} else {
		WriteByte(MSG_MULTICAST, 0);
	}

	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);

	if (!cam)
		m_flIntermissionCycle = 0.0f;
	else
		m_flIntermissionCycle = time + 5.0f;
	
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

	/* friendly fire */
	if (autocvar_sv_friendlyFire == false)
	if (t != c)
	if (IsTeamplay()) {
		if (t.flags & FL_CLIENT && c.flags & FL_CLIENT)
			if (t.team == c.team)
				return;
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
			g_dmg_eAttacker = c;
			g_dmg_eTarget = t;
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
	g_dmg_eAttacker = c;
	g_dmg_eTarget = t;
	g_dmg_iDamage = dmg;
	g_dmg_iHitBody = trace_surface_id;
	g_dmg_iFlags = type;
	g_dmg_iWeapon = w;

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
NSGameRules::DamageRadius(vector org, entity attacker, float dmg, float r, int check, int w)
{
	float new_dmg;
	float dist;
	float diff;
	vector pos;

	for (entity e = world; (e = findfloat(e, ::takedamage, DAMAGE_YES));) {
		pos[0] = e.absmin[0] + (0.5 * (e.absmax[0] - e.absmin[0]));
		pos[1] = e.absmin[1] + (0.5 * (e.absmax[1] - e.absmin[1]));
		pos[2] = e.absmin[2] + (0.5 * (e.absmax[2] - e.absmin[2]));

		/* don't bother if it's not anywhere near us */
		dist = vlen(org - pos);
		if (dist > r)
			continue;

		/* can we physically hit this thing? */
		if (check == TRUE)
			if (DamageCheckTrace(e, org) == FALSE)
				continue;

		/* calculate new damage values */
		diff = (r - dist) / r;
		new_dmg = rint(dmg * diff);

		if (diff > 0) {
			g_dmg_vecLocation = org;
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

	if (!(input_buttons & INPUT_BUTTON0) && !(input_buttons & INPUT_BUTTON2))
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
