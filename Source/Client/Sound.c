/*
	Copyright 2016-2018 Marco "eukara" Hladik
	
	MIT LICENSE

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software and associated documentation 
	files (the "Software"), to deal in the Software without 
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or
	sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
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
