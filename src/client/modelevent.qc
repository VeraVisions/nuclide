/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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
void
Event_EjectShell(void)
{
	static void Event_EjectShell_Death(void) {
		remove(self);
	}
	vector vEndPos;

	if (!pSeat->m_fEjectModel)
		return;

	
	entity eShell = spawn();
	eShell.modelindex = pSeat->m_fEjectModel;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * pSeat->m_vecEjectVel[0]);
	eShell.velocity += (v_right * pSeat->m_vecEjectVel[1]);
	eShell.velocity += (v_up * pSeat->m_vecEjectVel[2]);

	eShell.avelocity = [0,45,900];
	eShell.think = Event_EjectShell_Death;
	eShell.nextthink = time + 2.5f;
	pSeat->m_fEjectModel = 0;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_vecEjectPos);
}

/*
====================
Event_ProcessModel

Called by the engine whenever a model
tries to play an event.
====================
*/
void
Event_ProcessModel(float flTimeStamp, int iCode, string strData)
{
	switch(iCode) {
	case 5004: /* view model sound */
		localsound(strData, CHAN_AUTO, 1.0);
		break;
	case 5001: /* muzzle flash on attachment 0 */
		pSeat->m_eMuzzleflash.alpha = 1.0f;
		pSeat->m_eMuzzleflash.scale = 0.25;
		pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones;
		Event_EjectShell();
		break;
	case 5011: /* muzzle flash on attachment 1 */
		pSeat->m_eMuzzleflash.alpha = 1.0f;
		pSeat->m_eMuzzleflash.scale = 0.25;
		pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones + 1;
		Event_EjectShell();
		break;
	case 5021: /* muzzle flash on attachment 2 */
		pSeat->m_eMuzzleflash.alpha = 1.0f;
		pSeat->m_eMuzzleflash.scale = 0.25;
		pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones + 2;
		Event_EjectShell();
		break;
	case 5031: /* muzzle flash on attachment 3 */
		pSeat->m_eMuzzleflash.alpha = 1.0f;
		pSeat->m_eMuzzleflash.scale = 0.25;
		pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones + 3;
		Event_EjectShell();
		break;
	}
}
