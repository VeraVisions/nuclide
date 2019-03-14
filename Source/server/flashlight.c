/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void Flashlight_Toggle(void)
{
	if (cvar("sv_playerslots") != 1) {
		if (cvar("mp_flashlight") != 1) {
			return;
		}
	}
	
	if (self.flags & FL_FLASHLIGHT) {
		self.flags &= ~FL_FLASHLIGHT;
	} else {
		self.flags |= FL_FLASHLIGHT;
	}
	sound(self, CHAN_ITEM, "items/flashlight1.wav", 1, ATTN_IDLE);
}
