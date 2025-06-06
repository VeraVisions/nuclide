/*
 * Copyright (c) 2016-2024 Vera Visions LLC.
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

bool
Util_IsPaused(void)
{
#ifdef CLIENT
	return serverkeyfloat(SERVERKEY_PAUSESTATE) == 1 ? true : false;
#else
	return false;
#endif
}

void
Util_Destroy(void)
{
	remove(self);
}

string
Util_TimeToString(float fTime)
{
	fTime = rint(fTime);

	switch (fTime) {
		case 0: return "less than one";
		case 1: return "one";
		case 2: return "two";
		case 3: return "three";
		case 4: return "four";
		case 5: return "five";
		case 6: return "six";
		case 7: return "seven";
		case 8: return "eight";
		case 9: return "nine";
		case 10: return "ten";
		default: return "over ten";
	}
}

/* returns whether or not the mode we're playing is a team game */
bool
Util_IsTeamplay(void)
{
#ifdef SERVER
	return g_grMode.IsTeamplay();
#else
	return (serverkeyfloat("teams") > 0) ? (true) : (false);
#endif
}

void
Util_ChangeClass(entity objectID, string className)
{
	entity oldSelf = self;
	self = objectID;
	callfunction(strcat("spawnfunc_", className));
	self = oldSelf;
}

string
Util_ChatFormat(float playerNum, float teamNum, string chatMessage)
{
	vector teamColor = stov(serverkey(sprintf("teamcolor_%d", teamNum)));
	string teamColorString = sprintf("^x%x%x%x", teamColor[0] * 15,teamColor[1] * 15,teamColor[2] * 15);
	string teamName = serverkey(sprintf("team_%d", teamNum));

#ifdef CLIENT
	string playerName = getplayerkeyvalue(playerNum, "name");
#else
	string playerName = infokey(edict_num(playerNum+1), "name");
#endif

	if (teamNum == 0) {
		return sprintf("%s^7: %s", playerName, chatMessage);
	} else {
		return sprintf("%s %s(%s)^7: %s", playerName, teamColorString, teamName, chatMessage);
	}
}

int
Util_GetMaxPlayers(void)
{
	return g_numplayerslots;
}

string
Util_GetTime( void )
{
	static int iS, iM, iT, iMS;
	float timeLimit = stof( serverkey( "timelimit" ) ) * 60;

	/* display a count-down timer if we've got a time limit */
	if (timeLimit <= 0)
		iMS = (int)time;
	else
		iMS = timeLimit - time;

	if ( iMS < 0 ) {
		iMS = 0;
	}
	
	iS = iMS;
	iM = iS / 60;
	iS -= iM * 60;
	iT = iS / 10;
	iS -= iT * 10;
	
	return sprintf( "%i:%i%i", iM, iT, iS );
}

float
Util_GetTimeLeft(void)
{
	float timeLimit = stof( serverkey( "timelimit" ) ) * 60;
	return timeLimit - time;
}

string
Util_GetAddress(void)
{
	string host = serverkey("ip");

	if (host == "QLoopBack:0")
		return "localhost";
	else
		return host;
}
