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

class CBot {
	entity huntenemy;	//who we're trying to hunt
	float wiggletime;
	float wiggleside;
	int iAttackMode;
	float flSwitchDelay;
	float flRouteDelay;
	string chat_next;
	float chat_nexttime;
	float flJumpNext;
	
	float reflextime;
	
	int teamrole;	//attack, defend, assist
	int iInGame; // so we can drop them in case they rejoin
	
	int nodes;
	int cur_node;
	nodeslist_t *route;
	
	// unstuckyness
	float node_giveup;
	float lastdist;
	float distcache;
	nonvirtual void( void ) RunAI;
	nonvirtual void( void ) CreateRandom;
	nonvirtual void( int iBotID ) Create;
};

var int autocvar_bot_ai = TRUE;
var float autocvar_bot_autoadd = 0;
var int autocvar_bot_skill = 3;

int iBots, iBotTotal;
void Bot_Init( void );

