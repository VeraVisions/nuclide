/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void View_UpdateWeapon(entity vm, entity mflash)
{
	int aw = getstati( STAT_ACTIVEWEAPON );
	if( aw < CS_WEAPON_COUNT ) {
			if ( pSeat->fLastWeapon != aw ) {
				pSeat->fLastWeapon = aw;
				if ( aw >= 1 ) {
					string wm;
					if (autocvar_skins_dir != "") {
						wm = sprintf("skins/%s/%s", autocvar_skins_dir, sViewModels[ aw - 1 ]);
					} else {
						wm = sprintf("models/%s", sViewModels[ aw - 1 ]);
					}
					setmodel( vm, wm );

					if (getstati_punf(STAT_TEAM) == TEAM_CT) {
						setcustomskin(vm, "", "geomset 0 2\n");
					} else {
						setcustomskin(vm, "", "geomset 0 1\n");
					}

					skel_delete( mflash.skeletonindex );
					mflash.skeletonindex = skel_create( vm.modelindex );
					pSeat->fNumBones = skel_get_numbones( mflash.skeletonindex ) + 1;
					pSeat->fEjectBone = pSeat->fNumBones + 1;
				}
			}
	}
}
