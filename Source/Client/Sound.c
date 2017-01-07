/*
OpenCS Project
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

/*float CSQC_Event_Sound( float entnum, float channel, string soundname, float vol, float attenuation, vector pos, float pitchmod, float flags ) {

}*/

/*
=================
Sound_Delayed

Now you can call sounds in advance
=================
*/
void Sound_Delayed( string sSample, float fVol, float fDelay ) {
	static void Sound_Delayed_PlayBack( void ) {
		//print( sprintf( "[SOUND] Playing Event %s\n", self.sSoundSample ) );
		localsound( self.sSoundSample, CHAN_AUTO, self.fVolume );
		remove( self );
	}
	entity eSound = spawn();
	eSound.think = Sound_Delayed_PlayBack;
	eSound.sSoundSample = sSample;
	eSound.fVolume = fVol;
	eSound.nextthink = time + fDelay;
}
