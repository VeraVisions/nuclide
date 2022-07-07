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

/*
=================
Client_FixAngle

Forces the camera-angle on the specified 'target' client
to the euler angle in the 'ang' parameter.
=================
*/
void
Client_FixAngle(entity target, vector ang)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_ANGLE);
	WriteFloat(MSG_MULTICAST, ang[0]);
	WriteFloat(MSG_MULTICAST, ang[1]);
	WriteFloat(MSG_MULTICAST, ang[2]);
	msg_entity = target;
	multicast([0,0,0], MULTICAST_ONE);
}

/*
=================
Client_ShakeOnce

Single unreliable request to shake the screen of all
players within a specified radius by the desired parameters.
=================
*/
void
Client_ShakeOnce(vector pos, float radius, float duration, float frequency, float amplitude)
{
	for (entity pl = world; (pl = find(pl, ::classname, "player"));) {
		float amp;

		if (vlen(pos - pl.origin) > radius)
			continue;

		amp = 1.0 - (vlen(pos - pl.origin) / radius);
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_SHAKE);
		WriteFloat(MSG_MULTICAST, duration);
		WriteFloat(MSG_MULTICAST, amplitude * amp);
		WriteFloat(MSG_MULTICAST, frequency);

		msg_entity = pl;
		multicast([0,0,0], MULTICAST_ONE);
	}
};

void
CSEv_TriggerTarget_s(string tname)
{
	if (tname)
	for (entity a = world; (a = find(a, ::targetname, tname));) {
		NSEntity t = (NSEntity)a;

		if (t.Trigger)
			t.Trigger(self, TRIG_TOGGLE);
	}
}
