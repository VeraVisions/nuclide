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

class CGameRules
{
	int m_iIntermission;
	float m_flIntermissionTime;
	float m_flIntermissionCycle;

	void() CGameRules;

	virtual void(void) InitPostEnts;

	/* logic */
	virtual void(void) FrameStart;
	virtual float(base_player,string) ConsoleCommand;

	/* client */
	virtual void(base_player) PlayerConnect;
	virtual void(base_player) PlayerDisconnect;
	virtual void(base_player) PlayerKill;
	virtual void(base_player) PlayerSpawn;
	virtual void(base_player) PlayerPreFrame;
	virtual void(base_player) PlayerPostFrame;
	virtual void(base_player) PlayerDeath;
	virtual void(base_player) PlayerPain;

	/* level transitions */
	virtual void(void) LevelNewParms;
	virtual void(base_player) LevelChangeParms;

	virtual int(int) MaxItemPerSlot;

	/* end of a game */
	virtual void(void) IntermissionStart;
	virtual void(void) IntermissionCycle;
	virtual void(void) IntermissionEnd;

	/* spectator */
	/*virtual void(base_player) SpectatorConnect;
	virtual void(base_player) SpectatorDisconnect;
	virtual void(base_player) SpectatorThink;*/
};

/* our currently running mode */
CGameRules g_grMode;
