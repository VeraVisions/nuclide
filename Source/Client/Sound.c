/*
FreeCS Project
Copyright (C) 2016, 2017 Marco "eukara" Hladik

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

typedef struct {
	string sSample;
	float fLength;
} sound_t;

sound_t *sndVOX;
var int iVOXCount;
var int iVOXPos;
var float fSampleTime = 0.0f;

void Sound_PlayVOX( string sMessage ) {
	if ( iVOXCount ) {
		return;
	}
	
	iVOXCount = tokenize( sMessage );
	sndVOX = memalloc( sizeof( sound_t ) * iVOXCount );
	
	for ( int i = 0; i < iVOXCount; i++ ) {
		sndVOX[i].sSample = sprintf( "vox/%s.wav", argv( i ) );
		sndVOX[i].fLength = soundlength( sndVOX[i].sSample );
	}
	fSampleTime = time;
}

void Sound_ProcessWordQue( void ) {
	if ( cltime < 2 ) {
		return;
	}
	if ( iVOXCount ) {
		if ( fSampleTime < time ) {
			localcmd( sprintf( "play %s\n", sndVOX[ iVOXPos ].sSample ) );	
			iVOXPos++;
			
			if ( iVOXPos == iVOXCount ) {
				memfree( sndVOX );
				iVOXCount = 0;
				iVOXPos = 0;
			} else {
				fSampleTime = time + sndVOX[ iVOXPos ].fLength;
			}
		}
	}
}