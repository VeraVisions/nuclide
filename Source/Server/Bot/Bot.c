/*
 * Copyright (c) 2015-2018
 * Marco Hladik  All rights reserved.
 *
 * This file is part of The Wastes's Source-Code.
 * 
 * The Wastes's Source-Code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * The Wastes's Source-Code is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with The Wastes's Source-Code.  If not, see <http://www.gnu.org/licenses/>.
 */

float bot_skill[] = {
	2.0f,
	1.75f,
	1.5f,
	1.0f,
	0.5,
	0.25f,
	0.0f
};

/*
=================
Bot_AutoAdd
=================
*/
void Bot_AutoAdd( void ) {
	if ( self.delay == TRUE ) {
		CBot bot;
		bot = (CBot)spawnclient();
		if ( bot ) {
			bot.CreateRandom();
			self.health--;
			if ( self.health ) {
				self.nextthink = time + 0.25f;
			} else {
				remove( self );
			}
		}
	} else {
		// Let's kill the bots that were here before, before they have not been initialized.
		for ( entity eFind = world; ( eFind = find( eFind, classname, "player" ) ); ) {
			if ( clienttype( eFind ) == CLIENTTYPE_BOT ) {
				dropclient( eFind );
			}
		}

		// Let's add new bots.
		float bots = autocvar_bot_autoadd;
		if ( bots >= cvar( "sv_playerslots" ) ) {
			bots = cvar( "sv_playerslots" ) - 1;
		}

		if ( !bots ) {
			remove( self );
			return;
		}

		self.delay = TRUE;
		self.health = bots;
		self.nextthink = time + 0.25f;
	}
}

/*
=================
Bot_Init
=================
*/
void Bot_Init( void )
{
	entity eBotAdder = spawn();
	eBotAdder.think = Bot_AutoAdd;
	eBotAdder.nextthink = time + 0.25f;
}

/*
=================
CBot::PickEnemy
=================
*/
void CBot::PickEnemy( void )
{
	if ( huntenemy && huntenemy.health > 0 ){
		return;
	}

	huntenemy = world;
	float bestdist = 99999999;

	for (entity e = world; (e = find(e, ::classname, "player")); ) {
			if ( e.team == self.team ) {
				continue;
			}
		if ( e.flags & FL_NOTARGET ) {
			continue; //cheat.
		}
		if ( e == this ) {
			continue; //no self-harm
		}
		if ( e.health > 0 ) {
			float dist = vlen(e.origin - origin);
			if ( dist < bestdist ) {
				traceline(origin+view_ofs, e.origin, TRUE, this);
				if (trace_ent == e || trace_fraction == 1) {
					bestdist = dist;
					huntenemy = e;
					reflextime = time;
					reflextime += bot_skill[ bound( 0, autocvar_bot_skill, bot_skill.length - 1 ) ];
					reflextime += ( random() * 0.25f );
				}
			}
		}
	}
};

void Bot_RouteCB(entity ent, vector dest, int numnodes, nodeslist_t *nodelist)
{
	CBot player = (CBot)ent;
	player.nodes = numnodes;
	player.cur_node = numnodes - 1;
	player.route = nodelist;

	dprint( "Bot: Route calculated.\n" );
	dprint( sprintf( "Bot: # of nodes: %i\n", numnodes )  );
	dprint( sprintf( "Bot: # current node: %i\n", player.cur_node )  );
	dprint( sprintf( "Bot: # endpos: %v\n", dest ) );
}

/*
=================
CBot::RunAI
=================
*/
void CBot::RunAI( void )
{
	if ( team <= 0 ) {
		bprint( "Selecting team\n" );
		CSEv_GamePlayerSpawn_f( floor( random( 1, 8 )  ));

		// If we couldn't spawn, don't even try doing stuff
		if ( health <= 0 ) {
			return;
		} else {
			if ( route ) {
				nodes = 0;
				memfree( route );
				huntenemy = __NULL__;
			}
		}
	}
	
	if ( autocvar_bot_ai == FALSE ) {
		return;
	}

	if ( nodes ) {
		PickEnemy();
	}

	input_buttons = 0;

	if ( !nodes ) {
		route_calculate( this, Route_SelectDestination(this), 0, Bot_RouteCB );
		bprint( "Route: Calculating first bot route\n" );
	}

	// Route might have been not been processed
	if ( !nodes ) {
		bprint( "Route: NO NODES\n" );
		return;
	}
	
	float dist = floor( vlen( route[cur_node].dest - origin ) );

	if ( dist < 64 ) {
		bprint( "Route: Reached node.\n" );
		cur_node--;
	}

	// We haven't gotten anywhere, start
	if ( dist == lastdist ) {
		node_giveup += frametime;
	}

	if ( node_giveup > 2.5f ) {
		bprint( "Route: Giving up route\n" );
		cur_node = -1;
		node_giveup = 0.0f;
	} else if ( node_giveup > 1.0f ) {
		makevectors( angles );
		tracebox( origin + '0 0 18', mins, maxs, origin + '0 0 18' + ( v_forward * 32 ), FALSE, this );
		if ( trace_fraction < 1.0f && flags & FL_ONGROUND ) {
			tracebox( origin + '0 0 64', mins, maxs, origin + '0 0 64' + ( v_forward * 32 ), FALSE, this );
			if ( trace_fraction == 1.0f ) {
				input_movevalues_z = 200;
			} else {
				tracebox(origin-'0 0 18', VEC_CHULL_MIN, VEC_CHULL_MAX, origin-'0 0 18'+(v_forward * 16), FALSE, this);
				if ( trace_fraction == 1.0f ) {
					input_movevalues_z = -200;
				}
			}
		}
	}
	if ( distcache < time ) {
		lastdist = dist;
		distcache = time + 2.0f;
	}
	// We haven't gotten anywhere, end

	if ( cur_node < 0 ) {
		bprint( "Route: Calculating new bot route\n" );
		nodes = 0;
		memfree( route );
		route_calculate( this, Route_SelectDestination(this), 0, Bot_RouteCB );
		return;
	}
	
	if ( huntenemy != __NULL__ ) {
		int enemyvisible;
		traceline( origin + view_ofs, huntenemy.origin, TRUE, this);
		enemyvisible = ( trace_ent == huntenemy || trace_fraction == 1.0f );
		
		if ( enemyvisible ) {
			angles = vectoangles( huntenemy.origin - origin );
			input_angles = angles;
			input_movevalues_x = 80;
			
			if ( !iAttackMode ) {
				input_buttons |= INPUT_BUTTON0; // Attack
			}
			iAttackMode = 1 - iAttackMode;
		} else {
			nodes = 0;
			memfree( route );
			route_calculate( this, huntenemy.origin, 0, Bot_RouteCB );
			huntenemy = __NULL__;
		}
	} else if ( nodes ) {
/*		
		if ( route[cur_node].linkflags & WP_JUMP && pmove_flags & PM_ONGROUND ) {
			dprint( "Bot: JUMP!\n" );
			input_movevalues_z = 200;
		}*/
		angles = vectoangles( route[cur_node].dest - origin );
		input_angles = angles;
		input_movevalues_x = 250;
	}
	
	tracebox( origin + '0 0 18', mins, maxs, origin + '0 0 18' + ( v_forward * 32 ), FALSE, this );
	if ( trace_fraction < 1.0f && flags & FL_ONGROUND ) {
			tracebox( origin + '0 0 18', mins, maxs, origin + '0 0 18' + ( v_forward * 32 ) + v_right * 16, FALSE, this );
			if ( trace_fraction == 1.0f ) {
				input_movevalues_y = 200;
			} else { 
				tracebox( origin + '0 0 18', mins, maxs, origin + '0 0 18' + ( v_forward * 32 ) + v_right * -16, FALSE, this );
			if ( trace_fraction == 1.0f ) {
				input_movevalues_y = -200;
			}
		}
	}

#if 1
	vector vNForward;
	float fLerpy = bound( 0.0f, 1.0f - ( frametime * 16 ), 1.0f );
	makevectors( input_angles );

	vNForward = v_forward;
	makevectors( v_angle );
	vNForward_x = Math_Lerp( vNForward_x, v_forward_x, fLerpy );
	vNForward_y = Math_Lerp( vNForward_y, v_forward_y, fLerpy );
	vNForward_z = Math_Lerp( vNForward_z, v_forward_z, fLerpy );
	input_angles = vectoangles( vNForward );
	v_angle = input_angles;
	angles = input_angles;
#else
	v_angle = input_angles;
#endif
	button0 = input_buttons & INPUT_BUTTON0; //attack
	//.button1 was meant to be +use, but the bit was never assigned and mods used button1 as a free field. there still is no button 1.
	button2 = input_buttons & INPUT_BUTTON2; //jump
	button3 = input_buttons & INPUT_BUTTON3; //tertiary
	button4 = input_buttons & INPUT_BUTTON4; //reload
	button5 = input_buttons & INPUT_BUTTON5; //secondary
	button6 = input_buttons & INPUT_BUTTON6; //unused
	//button7 = input_buttons & INPUT_BUTTON7; //sprint
	movement = input_movevalues;
	
	//runplayerphysics();
}

/*
=================
CBot::CreateRandom
=================
*/
void CBot::CreateRandom( void ) {
	Create( iBots );
	iBots++;
	if ( iBots >= iBotTotal ) {
		iBots = 0;
	}
}

/*
=================
CBot::Create
=================
*/
void CBot::Create( int iBotID )
{
	forceinfokey( self, "name", "Bot" );

	iInGame = TRUE;

	ClientConnect();
	PutClientInServer();
}
