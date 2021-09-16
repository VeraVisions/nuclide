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
	static CBaseEntity cam;
	CBaseEntity targ;

	if (!m_iIntermission)
		return;

	if (time < m_flIntermissionCycle)
		return;

	/* make the clients aware */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_INTERMISSION);

	cam = (CBaseEntity)find(cam, ::classname, "info_intermission");

	if (cam) {
		targ = (CBaseEntity)find(world, ::targetname, cam.target);

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
