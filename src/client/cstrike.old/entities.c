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

void
CSQC_ambient_generic(string sSample, float fVolume, float fAttenuation, float fLoop, float lFORate) {
	//print(sprintf("SOUND: %s, %f, %d\n%d %d %d", sSample, fVolume, fAttenuation, self.origin[0], self.origin[1], self.origin[2]));
	static void LFOHack (void) {
		sound(self, CHAN_VOICE, self.classname, self.movetype, self.style, 0, 0);
		self.nextthink = self.solid + time;
	}
	// Hack
	if (lFORate) {
		self.classname = sSample;
		self.movetype = fVolume;
		self.style = fAttenuation;
		self.think = LFOHack;
		self.solid = lFORate / 10;
		self.nextthink = self.solid + time;
		fLoop = FALSE;
	}
	
	/*if (fLoop) {
		sound(self, CHAN_VOICE, sSample, fVolume, fAttenuation, 0, SOUNDFLAG_FORCELOOP);
	} else {*/
		sound(self, CHAN_VOICE, sSample, fVolume, fAttenuation, 0, 0);
	//}
}

int
Game_Entity_Update(float id, float new)
{
	switch (id) {
	default:
		return FALSE;
	}

	return TRUE;
}

void
CSQC_Ent_Remove(void) {
	if (self.eGunModel) {
		remove(self.eGunModel);
	}
	
	soundupdate(self, CHAN_VOICE, "", -1, ATTN_IDLE, 0, 0, 0);
	remove(self);
}

