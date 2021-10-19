/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

/* init */
void
CGameRules::InitPostEnts(void)
{
	//print("Init!\n");
}

/* logic */
void
CGameRules::FrameStart(void)
{
	//print("StartFrame!\n");
}
float
CGameRules::ConsoleCommand(base_player pl, string cmd)
{
	return (0);
}

/* client */
void
CGameRules::PlayerConnect(base_player pl)
{
	//print("ClientConnect!\n");
}
void
CGameRules::PlayerDisconnect(base_player pl)
{
	//print("ClientDisconnect!\n");
}
void
CGameRules::PlayerKill(base_player pl)
{
	//print("PlayerKill!\n");
}
void
CGameRules::PlayerDeath(base_player pl)
{
	//print("PlayerDeath!\n");
}
void
CGameRules::PlayerPain(base_player pl)
{
	//print("ClientKill!\n");
}
void
CGameRules::PlayerSpawn(base_player pl)
{
	//print("PutClientInServer!\n");
}
void
CGameRules::PlayerPreFrame(base_player pl)
{
	//print("PlayerPreThink!\n");
}
void
CGameRules::PlayerPostFrame(base_player pl)
{
	//print("PlayerPostThink!\n");
}

/* level transitions */
void
CGameRules::LevelNewParms(void)
{
	//print("LevelNewParms!\n");
}
void
CGameRules::LevelChangeParms(base_player pl)
{
	//print("LevelChangeParms!\n");
}

/* spectator */
/*void
CGameRules::SpectatorConnect(player pl)
{
	//print("SpectatorConnect!\n");
}
void
CGameRules::SpectatorDisconnect(player pl)
{
	//print("SpectatorDisconnect!\n");
}
void
CGameRules::SpectatorThink(player pl)
{
	//print("SpectatorThink!\n");
}*/

int
CGameRules::MaxItemPerSlot(int slot)
{
	return (-1);
}

void
CGameRules::IntermissionStart(void)
{
	if (m_iIntermission)
		return;

	m_iIntermission = TRUE;
	m_flIntermissionTime = time + 5.0f;
}

void
CGameRules::IntermissionCycle(void)
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

int
CGameRules::MonstersSpawn(void)
{
	return (TRUE);
}

void
CGameRules::DamageApply(entity t, entity c, float dmg, int w, damageType_t type)
{
	/* Damage */
	base_player tp = (base_player)t;

	/* player god mode */
	if (t.flags & FL_CLIENT && t.flags & FL_GODMODE)
		return;

	/* already dead, please avoid recursion */
	if (t.health <= 0)
		return;

	/* only clients have armor */
	if (t.flags & FL_CLIENT) {
		/* skip armor */
		if not (type & DMG_SKIP_ARMOR)
		if (tp.armor && dmg > 0) {
			float flArmor;
			float flNewDamage;

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
	t.health -= dmg;

	/* the globals... */
	g_dmg_eAttacker = c;
	g_dmg_eTarget = t;
	g_dmg_iDamage = dmg;
	g_dmg_iHitBody = trace_surface_id;
	g_dmg_iFlags = type;
	g_dmg_iWeapon = w;

	if (dmg > 0) {
		t.dmg_take = dmg;
		t.dmg_inflictor = c;
	} else if (t.max_health && t.health > t.max_health) {
		t.health = t.max_health;
	}

	NSSurfacePropEntity s = (NSSurfacePropEntity)t;

	if (s.health <= 0) {
		if (s.flags & FL_CLIENT) {
			PlayerDeath((player)s);
		} else {
			s.Death();
		}
	} else {
		if (s.flags & FL_CLIENT) {
			PlayerPain((player)s);
		} else {
			s.Pain();
		}
	}
}

/* checks if we can hit an entity at 5 of the same spots */
int
CGameRules::DamageCheckTrace(entity t, vector vecHitPos)
{
	/* We're lazy. Who cares */
	if (t.solid == SOLID_BSP) {
		return (TRUE);
	}

	traceline(vecHitPos, t.origin, 1, self);
	if (trace_fraction == 1) {
		return (TRUE);
	}
	traceline(vecHitPos, t.origin + [15,15,0], 1, self);
	if (trace_fraction == 1) {
		return (TRUE);
	}
	traceline(vecHitPos, t.origin + [-15,-15,0], 1, self);
	if (trace_fraction == 1) {
		return (TRUE);
	}
	traceline(vecHitPos, t.origin + [-15,15,0], 1, self);
	if (trace_fraction == 1) {
		return (TRUE);
	}
	traceline(vecHitPos, t.origin + [15,-15,0], 1, self);
	if (trace_fraction == 1) {
		return (TRUE);
	}

	return (FALSE);
}

void
CGameRules::DamageRadius(vector org, entity attacker, float dmg, float r, int check, int w)
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
CGameRules::IntermissionEnd(void)
{
	if (!m_iIntermission)
		return;

	if (time < m_flIntermissionTime)
		return;

	if (!(input_buttons & INPUT_BUTTON0) && !(input_buttons & INPUT_BUTTON2))
		return;

	localcmd("restart\n");
}

void
CGameRules::CGameRules(void)
{
	forceinfokey(world, "teamplay", "0");
}

/* our currently running mode */
CGameRules g_grMode;
