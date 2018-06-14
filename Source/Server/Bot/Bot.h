/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
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

