/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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
Event_ServerModelEvent

Handles standard/fallback model events. This should never be called directly
but instead be the default fallback for Game_ServerModelEvent.

The 'self' global is the entity the model-event is being run on.
=================
*/
void
Event_ServerModelEvent(float flTimeStamp, int iCode, string strData)
{
	switch (iCode) {
	case 1003:
		for (entity f = world; (f = find(f, ::targetname, strData));) {
			NSEntity trigger = (NSEntity)f;
			if (trigger.Trigger != __NULL__) {
				trigger.Trigger(self, TRIG_TOGGLE);
				dprint(sprintf("^2%s^7::^3ModelEvent^7: " \
					"Calling trigger '%s'\n",
					self.classname, strData));
			}
		}
		break;
	case 1004:
		break;
	default:
		dprint(sprintf("^3[SERVER]^7 Unknown model-event code " \
			"%i with data %s\n", iCode, strData));
		break;
	} 
}
