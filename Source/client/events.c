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

/*
====================
View_ShellEject

Spawns a shell tempentity. Looking fancy
====================
*/
void Event_EjectShell(void)
{
	static void Event_EjectShell_Death(void) {
		remove(self);
	}
	vector vOrigin = pSeat->vPlayerOrigin + [0, 0, getstatf(STAT_VIEWHEIGHT)];
	vector vEndPos = gettaginfo(pSeat->eViewModel, pSeat->fEjectBone);
	makevectors(view_angles);
	
	vOrigin += (v_forward * vEndPos[0]);
	vOrigin += (v_right * -vEndPos[1]);
	vOrigin += (v_up * vEndPos[2]) ;
	
	entity eShell = spawn();
	setorigin(eShell, vOrigin);
#ifdef CSTRIKE
	setmodel(eShell, sShellModel[wptTable[getstati(STAT_ACTIVEWEAPON)].iShellType]);
#endif
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [view_angles[0], view_angles[1], 0];
	eShell.velocity = pSeat->vPlayerVelocity;
	eShell.velocity += (v_up * random(70, 120));
	eShell.velocity += (v_right * -random(50, 70));
	eShell.avelocity = [0,45,900];
	eShell.think = Event_EjectShell_Death;
	eShell.nextthink = time + 2.5f; 
}

/*
====================
Event_ProcessModel

Called by the engine whenever a model
tries to play an event.
====================
*/
void Event_ProcessModel(float fTimeStamp, int iCode, string sData)
{
	if (iCode == 5004) {
		localsound(sData, CHAN_AUTO, 1.0);
	} else if (iCode == 5001) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones;
		setmodel(pSeat->eMuzzleflash, sprintf("sprites/muzzleflash%s.spr", substring(sData, 1, 1)));
		Event_EjectShell();
	} else if(iCode == 5011) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones + 1;
		setmodel(pSeat->eMuzzleflash, sprintf("sprites/muzzleflash%s.spr", substring(sData, 1, 1)));
		Event_EjectShell();
	} else if (iCode == 5021) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones + 2;
		setmodel(pSeat->eMuzzleflash, sprintf("sprites/muzzleflash%s.spr", substring(sData, 1, 1)));
		Event_EjectShell();
	} else if (iCode == 5031) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones + 3;
		setmodel(pSeat->eMuzzleflash, sprintf("sprites/muzzleflash%s.spr", substring(sData, 1, 1)));
		Event_EjectShell();
	}
}
