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

void
bot::CheckRoute(void)
{
	float flDist;
	vector evenpos;

	if (!m_iNodes) {
		return;
	}

	/* level out position/node stuff */
	if (m_iCurNode < 0) {
		evenpos = m_vecLastNode;
		evenpos[2] = origin[2];
	} else {
		evenpos = m_pRoute[m_iCurNode].m_vecDest;
		evenpos[2] = origin[2];
	}

	flDist = floor(vlen(evenpos - origin));

	if ( flDist < 16 ) {
		dprint(sprintf("^2CBaseMonster::^3CheckRoute^7: " \
			"%s reached node\n", this.targetname));
		m_iCurNode--;
		velocity = [0,0,0]; /* clamp friction */

		/* we've still traveling and from this node we may be able to walk
		 * directly to our end-destination */
		if (m_iCurNode > -1) {
			tracebox(origin, mins, maxs, m_vecLastNode, MOVE_NORMAL, this);

			/* can we walk directly to our target destination? */
			if (trace_fraction == 1.0) {
				dprint("^2CBaseMonster::^3CheckRoute^7: " \
					"Walking directly to last node\n");
				m_iCurNode = -1;
			}
		}
	} else {
		traceline( origin + view_ofs, m_pRoute[m_iCurNode].m_vecDest, MOVE_NORMAL, this );

		/* we can't trace against our next waypoint... that should never happen */
		if ( trace_fraction != 1.0f ) {
			m_flNodeGiveup += frametime;
		} else {
			/* if we're literally stuck in a corner aiming at something we should
			 * not, also give up */
			if ( flDist == m_flLastDist ) {
				m_flNodeGiveup += frametime;
			} else {
				m_flNodeGiveup = bound( 0, m_flNodeGiveup - frametime, 1.0 );
			}
		}
	}

	m_flLastDist = flDist;

	if ( m_flNodeGiveup >= 1.0f ) {
		dprint(sprintf("bot::CheckRoute: %s gave up route\n",
			this.netname));

		m_iCurNode = -2;
		m_flNodeGiveup = 0.0f;
	} else if ( m_flNodeGiveup >= 0.5f ) {
		input_buttons |= INPUT_BUTTON2;
	}

	if (m_iCurNode < -1) {
		dprint(sprintf("bot::CheckRoute: %s calculates new route\n",
			this.netname));

		m_iNodes = 0;
		memfree( m_pRoute );
		route_calculate( this, Route_SelectDestination( this ), 0, Bot_RouteCB );
		return;
	}
}

void
bot::RunAI(void)
{
	vector aimdir, aimpos;
	int enemyvisible, enemydistant;
	float flLerp;

	/* reset input frame */
	input_buttons = 0;
	input_movevalues = [0,0,0];
	input_angles = [0,0,0];

	/* attempt to respawn when dead */
	if (health <= 0) {
		input_buttons |= INPUT_BUTTON0;
	}

	/* create our first route */
	if (!m_iNodes) {
		route_calculate(this, Route_SelectDestination(this), 0, Bot_RouteCB);

		dprint(sprintf("bot::RunAI: %s is calculating first bot route\n",
			this.netname));

		/* our route probably has not been processed yet */
		if (!m_iNodes) {
			return;
		}
	}

	//WeaponThink();
	//PickEnemy();

	enemyvisible = FALSE;
	enemydistant = FALSE;

	if (m_eTarget != __NULL__) {
		traceline(origin + view_ofs, m_eTarget.origin, TRUE, this);
		enemyvisible = (trace_ent == m_eTarget || trace_fraction == 1.0f);

		if (vlen(trace_endpos - origin) > 1024) {
			enemydistant = TRUE;
		}

		if (enemyvisible) {
			//WeaponAttack();
		}
	}

	CheckRoute();

	if (m_iNodes) {
		if (!m_eTarget || !enemyvisible) {
			/* aim at the next node */
			if (m_iCurNode == -1)
				aimpos = m_vecLastNode;
			else
				aimpos = m_pRoute[m_iCurNode].m_vecDest;
		} else {
			/* aim towards the enemy */
			aimpos = m_eTarget.origin;
		}

		/* lerping speed */
		flLerp = bound(0.0f, 1.0f - (frametime * 15), 1.0f);

		/* that's the old angle */
		makevectors(v_angle);
		vector vNewAngles = v_forward;

		/* aimdir = final angle */
		aimdir = vectoangles(aimpos - origin);
		makevectors(aimdir);

		/* slowly lerp towards the final angle */
		vNewAngles[0] = Math_Lerp(vNewAngles[0], v_forward[0], flLerp);
		vNewAngles[1] = Math_Lerp(vNewAngles[1], v_forward[1], flLerp);
		vNewAngles[2] = Math_Lerp(vNewAngles[2], v_forward[2], flLerp);

		/* make sure we're aiming tight */
		v_angle = vectoangles(vNewAngles);
		v_angle[0] = Math_FixDelta(v_angle[0]);
		v_angle[1] = Math_FixDelta(v_angle[1]);
		v_angle[2] = Math_FixDelta(v_angle[2]);
		input_angles = v_angle;
		angles[0] = Math_FixDelta(v_angle[0]);
		angles[1] = Math_FixDelta(v_angle[1]);
		angles[2] = Math_FixDelta(v_angle[2]);

		/* now we'll set the movevalues relative to the input_angle */
		vector direction = normalize(aimpos - origin) * 240;
		makevectors(input_angles);
		input_movevalues = [v_forward * direction, v_right * direction, v_up * direction];
	}

	/* press any buttons needed */
	button0 = input_buttons & INPUT_BUTTON0; //attack
	button2 = input_buttons & INPUT_BUTTON2; //jump
	button3 = input_buttons & INPUT_BUTTON3; //tertiary
	button4 = input_buttons & INPUT_BUTTON4; //reload
	button5 = input_buttons & INPUT_BUTTON5; //secondary
	button6 = input_buttons & INPUT_BUTTON6; //use
	button7 = input_buttons & INPUT_BUTTON7; //unused
	button8 = input_buttons & INPUT_BUTTON8; //duck
	movement = input_movevalues;
}

void
bot::bot(void)
{
}
