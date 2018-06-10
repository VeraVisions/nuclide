/*
 * Copyright (c) 2015-2018
 * Marco Hladik  All rights reserved.
 *
 * This file is part of The Wastes's Source-Code.
 * 
 * The Wastes's Source-Code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * The Wastes's Source-Code is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with The Wastes's Source-Code.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Begin calculating a route. 
 * The callback function will be called once the route has finished being calculated. 
 * The route must be memfreed once it is no longer needed. 
 * The route must be followed in reverse order (ie: the first node that must be reached 
 * is at index numnodes-1). If no route is available then the callback will be called with no nodes.
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
