/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
====================
View_ShellEject

Spawns a shell tempentity. Looking fancy
====================
*/
void Event_EjectShell(void)
{
	static void Event_EjectShell_Death(void) {
		remove( self );
	}
	vector vOrigin = pSeat->vPlayerOrigin;
	vector vEndPos = gettaginfo( pSeat->eViewModel, pSeat->fEjectBone );
	makevectors( view_angles );
	
	vOrigin += ( v_forward * vEndPos_x ) + ( v_right * -vEndPos_y ) + ( v_up * vEndPos_z ) + [ 0, 0, getstatf( STAT_VIEWHEIGHT ) ];
	
	entity eShell = spawn();
	setorigin( eShell, vOrigin );
#ifdef CSTRIKE
	setmodel( eShell, sShellModel[ wptTable[ getstati( STAT_ACTIVEWEAPON ) ].iShellType ] );
#endif
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [ view_angles_x, view_angles_y, 0 ];
	eShell.velocity = pSeat->vPlayerVelocity + ( v_up * random( 70, 120 ) ) + ( v_right * -random( 50, 70 ) );
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
void Event_ProcessModel( float fTimeStamp, int iCode, string sData )
{
	if ( iCode == 5004 ) {
		localsound( sData, CHAN_AUTO, 1.0 );
	} else if ( iCode == 5001 ) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones;
		setmodel( pSeat->eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
		Event_EjectShell();
	} else if( iCode == 5011 ) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones + 1;
		setmodel( pSeat->eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
		Event_EjectShell();
	} else if ( iCode == 5021 ) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones + 2;
		setmodel( pSeat->eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
		Event_EjectShell();
	} else if ( iCode == 5031 ) {
		pSeat->eMuzzleflash.alpha = 1.0f;
		pSeat->eMuzzleflash.scale = 0.5;
		pSeat->eMuzzleflash.skin = pSeat->fNumBones + 3;
		setmodel( pSeat->eMuzzleflash, sprintf( "sprites/muzzleflash%s.spr", substring( sData, 1, 1 ) ) );
		Event_EjectShell();
	}
}
