/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

/*QUAKED point_message (1 0 0) (-8 -8 -8) (8 8 8)
"message"       The message to display.
"radius"        The radius in which it will appear.

Client-side overlay/message that is projected in relation to its position
in 3D space.
Used for zoo and test maps in which less interactive overlays are desired.
*/

class point_message:CBaseEntity
{
	float m_flRadius;
	string m_strMessage;
	void() point_message;
	virtual void(string, string) SpawnKey;
};

void point_message::SpawnKey(string strField, string strKey)
{
	switch (strField) {
		case "radius":
			m_flRadius = stof(strKey);
			break;
		case "message":
			m_strMessage = strKey;
			break;
		case "origin":
			origin = stov( strKey );
			setorigin( this, origin );
			break;
		default:
			CBaseEntity::SpawnKey(strField, strKey);
	}
}

void point_message::point_message(void)
{
	m_flRadius = 512;
	m_strMessage = "No message";
	Init();
}

int PointMessage_Visible( vector p1, vector p2, vector ang)
{
	vector delta;
	float fov;

	makevectors( ang );
	delta = normalize ( p1 - p2 );
	fov = delta * v_forward;

	if ( fov > 0.3 ) {
		traceline( p2, p1, TRUE, self );
		if ( trace_fraction == 1.0 ) {
			return TRUE;
		}
	}
	return FALSE;
}

void PointMessage_Draw(void)
{
	string msg;
	float distance;
	vector vecPlayer;

#ifdef WASTES
	vecPlayer = viewClient.vecPlayerOrigin;
	vecPlayer += [ 0, 0, getstatf( ST_VIEWHEIGHT ) ];
#else
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &seats[s];
	vecPlayer = pSeat->vPlayerOrigin;
#endif

#ifdef WASTES
	for ( entity eFind = world; ( eFind = find( eFind, ::classname, "point_message" ) ); ) {
		point_message m = (point_message)eFind;
		msg = m.m_strMessage;
		distance = vlen(m.origin - vecPlayer);

		if (distance > m.m_flRadius) {
			continue;
		}

		if ( PointMessage_Visible( m.origin, vecPlayer, getproperty( VF_ANGLES )) == TRUE ) {
			vector vTemp = project( m.origin ) - [ ( stringwidth( msg, FALSE,[8,8] ) / 2 ), 0];
			Gfx_String( vTemp, msg, [8,8], autocvar_hud_color, 1.0f, FNT_GAME);
		}
	}
#endif
}
