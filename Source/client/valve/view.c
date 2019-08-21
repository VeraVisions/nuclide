/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

void View_UpdateWeapon(entity vm, entity mflash)
{
	player pl = (player)pSeat->ePlayer;
	
	if (pSeat->fLastWeapon != pl.activeweapon) {
		pSeat->fLastWeapon = pl.activeweapon;
		if (pl.activeweapon) {
			Weapons_Draw();
			skel_delete( mflash.skeletonindex );
			mflash.skeletonindex = skel_create( vm.modelindex );
			pSeat->fNumBones = skel_get_numbones( mflash.skeletonindex ) + 1;
			pSeat->fEjectBone = pSeat->fNumBones + 1;
		}
	}
}
