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

void View_UpdateWeapon(entity vm, entity mflash)
{
	int aw = getstati(STAT_ACTIVEWEAPON);
	if(aw < CS_WEAPON_COUNT) {
			if (pSeat->m_iLastWeapon != aw) {
				pSeat->m_iLastWeapon = aw;
				if (aw >= 1) {
					string wm;
					if (autocvar_skins_dir != "") {
						wm = sprintf("skins/%s/%s", autocvar_skins_dir, sViewModels[aw - 1]);
					} else {
						wm = sprintf("models/%s", sViewModels[aw - 1]);
					}
					setmodel(vm, wm);

					if (getstati_punf(STAT_TEAM) == TEAM_CT) {
						setcustomskin(vm, "", "geomset 0 2\n");
					} else {
						setcustomskin(vm, "", "geomset 0 1\n");
					}

					skel_delete(mflash.skeletonindex);
					mflash.skeletonindex = skel_create(vm.modelindex);
					pSeat->m_iVMBones = skel_get_numbones(mflash.skeletonindex) + 1;
					pSeat->m_iVMEjectBone = pSeat->m_iVMBones + 1;
				}
			}
	}
}
