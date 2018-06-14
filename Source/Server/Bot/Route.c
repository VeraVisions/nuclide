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

vector Route_SelectDestination( CBot target )
{
	entity dest = world;

	// Need health!
/*	if ( target.health < 50 ) {
		entity temp;
		int bestrange = 999999;
		int range;
		for ( temp = world; ( temp = find( temp, classname, "ItemHealth" ) ); ) {
			range = vlen( temp.origin - target.origin );
			if ( ( range < bestrange ) && ( temp.solid = SOLID_TRIGGER ) ) {
				bestrange = range;
				dest = temp;
			}
		}

		if ( dest ) {
			dprint( "Route: Going for health!" );
			return dest.origin + '0 0 32';
		}
	}

	// Handle the whole flag situation
	if ( iGame == MODE_CTF ) {
		if ( target.flags & FL_HASFLAG ) {
			if ( target.team == world.team1 ) {
				dest = find( world, classname, "CTFFlag1" );
			} else {
				dest = find( world, classname, "CTFFlag2" );
			}
			return dest.origin + '0 0 32';
		} else {
			if ( target.team == world.team1 ) {
				dest = find( world, classname, "CTFFlag2" );
			} else {
				dest = find( world, classname, "CTFFlag1" );
			}
			
			if ( dest.solid == SOLID_TRIGGER ) {
				return dest.origin + '0 0 32';
			}
		}
	}*/

	if ( target.team == TEAM_T ) {
		dest = Spawn_FindSpawnPoint( TEAM_CT );
	} else {
		dest = Spawn_FindSpawnPoint( TEAM_T );
	}

	return dest.origin;
}
