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

#define COST_INFINITE 99999

enum
{
	BOT_PERSONALITY_NORMAL,
	BOT_PERSONALITY_AGRESSIVE,
	BOT_PERSONALITY_DEFENSIVE
};

class bot:player
{
	/* routing */
	int m_iNodes;
	int m_iCurNode;
	nodeslist_t *m_pRoute;
	float m_flNodeGiveup;
	float m_flLastDist;
	entity m_eDestination;
	vector m_vecLastNode;

	/* combat */
	entity m_eTarget;
	int m_iAttackMode;
	float m_flAttackTime;

	/* items */
	int m_iOldItems;

	/* visual */
	float m_flSeeTime;

	/* cache, these are just here so we won't have to calc them often */
	float m_flEnemyDist;
	weapontype_t m_wtWeaponType;

	void(void) bot;

	virtual void(string) ChatSay;
	virtual void(string) ChatSayTeam;
	virtual void(void) Pain;
	virtual void(void) RouteClear;
	virtual void(void) WeaponThink;
	virtual void(void) WeaponAttack;
	virtual void(void) SeeThink;
	virtual void(int, int) BrainThink;
	virtual void(void) RunAI;
	virtual void(void) CreateObjective;
	virtual void(void) CheckRoute;
	virtual void(void) PreFrame;
	virtual void(void) PostFrame;
	virtual void(void) UseButton;
	virtual void(entity) SetEnemy;
	virtual float(void) GetRunSpeed;
	virtual float(void) GetWalkSpeed;
};

entity Bot_AddQuick(void);
