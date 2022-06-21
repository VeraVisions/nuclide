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
====================
Event_ProcessModel

Called by the engine whenever a model tries to play an event and isn't handled
by ClientGame_ModelEvent. This gives a mod the chance to override builtin
events - hook into them and all that.
====================
*/
void
Event_ProcessModel(float flTimeStamp, int iCode, string strData)
{
	switch(iCode) {
	case 1004:
		if (substring(strData, 0, 1) == "*")
			sound(self, CHAN_BODY, substring(strData, 1, -1), 1.0f, ATTN_NORM);
		else
			sound(self, CHAN_BODY, strData, 1.0f, ATTN_NORM);
		break;
	case 1005:
		NSTalkMonster targ = (NSTalkMonster)self;
		targ.Sentence(strData);
		break;
	case 1008:
		if (substring(strData, 0, 1) == "*")
			sound(self, CHAN_VOICE, substring(strData, 1, -1), 1.0f, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, strData, 1.0f, ATTN_NORM);
		break;
	case 5004: /* view model sound */
		localsound(strData, CHAN_AUTO, 1.0);
		break;
	case 5001: /* muzzle flash on attachment 0 */
		pSeat->m_eMuzzleflash.alpha = 1.0f;
		pSeat->m_eMuzzleflash.scale = 0.25;
		pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones;
		break;
	case 5011: /* muzzle flash on attachment 1 */
		pSeat->m_eMuzzleflash.alpha = 1.0f;
		pSeat->m_eMuzzleflash.scale = 0.25;
		pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones + 1;
		break;
	case 5021: /* muzzle flash on attachment 2 */
		pSeat->m_eMuzzleflash.alpha = 1.0f;
		pSeat->m_eMuzzleflash.scale = 0.25;
		pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones + 2;
		break;
	case 5031: /* muzzle flash on attachment 3 */
		pSeat->m_eMuzzleflash.alpha = 1.0f;
		pSeat->m_eMuzzleflash.scale = 0.25;
		pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones + 3;
		break;
	default:
		print(sprintf("Unknown model event: %f %i %S\n", flTimeStamp, iCode, strData));
	}
}

/*
====================
Event_Callback

Calls one event based on viewmodel frame timeline, to avoid running more than once.
Prediction runs through weapon many times per frame, so we have to do call special
events based on time passed on the viewmodel.
====================
*/
void
Event_Callback(float mtime, __inout float btime)
{
	/* don't bother if no valid function is set */
	if (pSeat->m_pEventCall == __NULL__)
		return;

	/* if the sequence ain't the same anymore... */
	if (pSeat->m_flEventFrame != pSeat->m_eViewModel.frame)
		return;

	/* if the model changed... */
	if (pSeat->m_flEventMdl != pSeat->m_eViewModel.modelindex)
		return;

	print(sprintf("%d %d %i\n", pSeat->m_flEventFrame, pSeat->m_flEventMdl, pSeat->m_iEventWeapon));

	/* weapon changed */
	player pl = (player)(pSeat->m_ePlayer);

	if (pSeat->m_iEventWeapon != pl.activeweapon)
		return;

	/* only play once */
	if (mtime == btime)
		return;

	/* call when we've passed the keyframe the first time */
	if (btime <= pSeat->m_flEventTime && (mtime > pSeat->m_flEventTime)) {
		pSeat->m_pEventCall();
		pSeat->m_pEventCall = __NULL__;
		pSeat->m_flEventMdl = 0;
		pSeat->m_flEventFrame = -1;
	}

	btime = mtime;
}
