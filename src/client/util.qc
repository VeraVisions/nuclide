/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
Client_IsSpectator(NSClient cl)
{
	if (cl.IsRealSpectator() || cl.IsFakeSpectator())
		return true;

	return false;
}

bool
Client_IsRealSpectator(NSClient cl)
{
	return cl.IsRealSpectator();
}

bool
Client_IsFakeSpectator(NSClient cl)
{
	return cl.IsFakeSpectator();
}

bool
Client_IsDead(NSClient cl)
{
	return cl.IsDead();
}

bool
Client_IsPlayer(NSClient cl)
{
	return cl.IsPlayer();
}

bool
Client_InVehicle(void)
{
	player pl = (player)pSeat->m_ePlayer;
	return (pl.vehicle != world) ? true : false;
}

/*
=================
Util_GetKeyString
=================
*/
string
Util_GetKeyString(string strBind)
{
	float flBindKey = tokenize(findkeysforcommandex(strBind, 0));
	string strBindTx = "";
	float j;

	for (j = 0; j < flBindKey; ++j) {
		if (strBindTx != "")
			strBindTx = strcat(strBindTx, ", ");

		strBindTx = strcat(strBindTx, argv(j));
	}

	if (!strBindTx)
		strBindTx = "UNBOUND";

	return strtoupper(strBindTx);
}

bool
Util_IsFocused(void)
{
	return g_focus;
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