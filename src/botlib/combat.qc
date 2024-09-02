/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
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
NSBot::Pain(entity inflictor, entity attacker, int damage, vector dir, int location)
{
	NSGameRules rules = g_grMode;

	super::Pain(inflictor, attacker, damage, dir, location);

	if (rules.IsTeamplay()) {
		if (isPlayer(attacker) && attacker.team == team) {
			ChatSayTeam("Stop shooting me!");
			return;
		}
	}

	/* make this pain our new enemy! */
	if (attacker && attacker != this) {
		float enemydist = distanceSquared(origin, m_eTarget.origin);
		float newdist = distanceSquared(origin, attacker.origin);

		if (m_eTarget) {
			if (newdist < enemydist) {
				SetEnemy(attacker);
			}
		} else {
			SetEnemy(attacker);
		}
	}
}

void
NSBot::SetEnemy(entity en)
{
	m_eTarget = en;

	if (m_eTarget) {
		m_flEnemyDist = distanceSquared(origin, m_eTarget.origin);
	} else {
		m_flEnemyDist = -1;
	}
}

void
NSBot::WeaponThink(void)
{
	bool isEmpty = m_activeWeapon.IsEmpty();

	/* clip empty, but the whole weapon isn't */
	if (isEmpty == false) {
		/* stop fire, tap reload */
		input_buttons &= ~INPUT_PRIMARY;
		input_buttons |= INPUT_RELOAD;
	} else {
		/* if empty, switch to the next best weapon */
		SwitchToBestWeapon(false);
	}

	//m_wtWeaponType = Weapons_GetType(this, activeweapon);
}

void
NSBot::WeaponAttack(void)
{
	bool shouldAttack = false;

	/* only attack when the type's suggested distance makes sense to */
	if (m_wtWeaponType == WPNTYPE_RANGED) {
		if (m_flEnemyDist <= 1024)
			shouldAttack = true;
	} else if (m_wtWeaponType == WPNTYPE_THROW) {
		if (m_flEnemyDist <= 512)
			shouldAttack = true;
	} else if (m_wtWeaponType == WPNTYPE_CLOSE) {
		if (m_flEnemyDist <= 128)
			shouldAttack = true;
	} else {
		if (m_flEnemyDist <= 1024)
			shouldAttack = true;
	}

	if (m_flForceWeaponAttack > time)
		shouldAttack = true;

	if (shouldAttack && m_flAttackTime < time) {
		if (!m_iAttackMode) {
			input_buttons |= INPUT_PRIMARY;
		}

		/* this might not affect much */
		if (m_wtWeaponType != WPNTYPE_FULLAUTO) {
			switch (cvar("bot_skill")) {
			case 1:
				m_flAttackTime = time + 0.25f;
				break;
			case 2:
				m_flAttackTime = time + 0.10f;
				break;
			case 3:
				m_flAttackTime = time + 0.05f;
				break;
			default:
				m_flAttackTime = time + 1.0;
			}
		}
	} else {
		input_buttons &= ~INPUT_PRIMARY;
		input_buttons &= ~INPUT_RELOAD;
		input_buttons &= ~INPUT_SECONDARY;
	}

	if (m_wtWeaponType != WPNTYPE_FULLAUTO)
		m_iAttackMode = 1 - m_iAttackMode;
	else
		m_iAttackMode = 0;
}

void
NSBot::ForceWeaponAttack(vector attackPos, float attackTime)
{
	m_vecForceWeaponAttackPos = attackPos;
	m_flForceWeaponAttack = attackTime + time;
}

var float g_botalert_timer;

void
BotLib_Alert(vector pos, float radius, float t)
{
	NSGameRules rules = g_grMode;

	/* sometimes many alert-sounds happen at once... we don't really want
	 * that */
	if (g_botalert_timer > time)
		return;

	for (entity w = world; (w = findfloat(w, ::identity, 1));) {
		if (isBot(w) == false) {
			continue;
		}

		/* out of radius */
		if (distance(pos, w.origin) > radius)
			continue;

		NSBot f = (NSBot) w;

		/* they already got a target of some kind */
		if (f.m_eTarget)
			continue;

		/* if they're our friend... ignore */
		if (rules.IsTeamplay())
			if (w.team == t)
				continue;

		/* if the bot is dead... ignore */
		if (f.health <= 0)
			continue;

		/* we've heard a noise. investigate the location */
		BotLog("Bot %S (%d) alerted by noise at %v", f.netname, num_for_edict(f), pos);
		f.RouteClear();
		f.RouteToPosition(pos);
	}

	g_botalert_timer = time + 0.5f;
}
