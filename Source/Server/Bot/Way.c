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

#define COST_INFINITE 999999999999

enumflags {
	WP_JUMP, //also implies that the bot must first go behind the wp...
	WP_CLIMB,
	WP_CROUCH,
	WP_USE
};

typedef struct waypoint_s {
	vector org;
	float flRadius;	//used for picking the closest waypoint. aka proximity weight. also relaxes routes inside the area.
	struct wpneighbour_s
	{
		int node;
		float linkcost;
		int iFlags;
	} *neighbour;
	int iNeighbours;
} waypoint_t;

static waypoint_t *waypoints;
static int iWaypoints;
static int bWaypointsLoaded;

static void() Way_WipeWaypoints=
{
	for (int i = 0; i < iWaypoints; i++)
		memfree(waypoints[i].neighbour);
	memfree(waypoints);
	iWaypoints = 0;
}

void Way_DumpWaypoints( string filename )
{
	float file = fopen(filename, FILE_WRITE);
	if (file < 0)
	{
		print("RT_DumpWaypoints: unable to open ", filename, "\n");
		return;
	}
	fputs(file, sprintf("%i\n", iWaypoints));
	for(int i = 0i; i < iWaypoints; i++)
	{
		fputs(file, sprintf("%v %f %i\n", waypoints[i].org, waypoints[i].flRadius, waypoints[i].iNeighbours));
		for(int j = 0i; j < waypoints[i].iNeighbours; j++)
			fputs(file, sprintf(" %i %f %#x\n", waypoints[i].neighbour[j].node, waypoints[i].neighbour[j].linkcost, (float)waypoints[i].neighbour[j].iFlags));
	}
	fclose(file);
}

void Way_ReadWaypoints( string filename )
{
	float file = fopen(filename, FILE_READ);
	bWaypointsLoaded = TRUE;
	if (file < 0)
	{
		print("Way_DumpWaypoints: unable to open ", filename, "\n");
		return;
	}
	Way_WipeWaypoints();
	
	tokenize(fgets(file));
	iWaypoints = stoi(argv(0));
	
	waypoints = memalloc(sizeof(*waypoints)*iWaypoints);
	for(int i = 0i; i < iWaypoints; i++)
	{
		tokenize(fgets(file));
		waypoints[i].org[0] = stof(argv(0));
		waypoints[i].org[1] = stof(argv(1));
		waypoints[i].org[2] = stof(argv(2));
		waypoints[i].flRadius = stof(argv(3));
		waypoints[i].iNeighbours = stoi(argv(4));
		waypoints[i].neighbour = memalloc(sizeof(*waypoints[i].neighbour)*waypoints[i].iNeighbours);
		for(int j = 0i; j < waypoints[i].iNeighbours; j++)
		{
			tokenize(fgets(file));
			waypoints[i].neighbour[j].node = stoi(argv(0));
			waypoints[i].neighbour[j].linkcost = stof(argv(1));
			waypoints[i].neighbour[j].iFlags = stoh(argv(2));
		}
	}
	fclose(file);
}

static void* memrealloc( __variant *oldptr, int elementsize, int oldelements, int newelements )
{
	void *n = memalloc(elementsize*newelements);
	memcpy(n, oldptr, elementsize*min(oldelements,newelements));
	memfree(oldptr);
	
	return n;
}

static void Way_LinkWaypoints( waypoint_t *wp, waypoint_t *w2 )
{
	int w2n = w2-waypoints;
	for (int i = 0i; i < wp->iNeighbours; i++)
	{
		if (wp->neighbour[i].node == w2n)
			return;
	}
	
	int idx = wp->iNeighbours++;
	wp->neighbour = memrealloc(wp->neighbour, sizeof(*wp->neighbour), idx, wp->iNeighbours);
	local struct wpneighbour_s *n = wp->neighbour+idx;
	n->node = w2n;
	n->linkcost = vlen(w2->org - wp->org);
	n->iFlags = 0;
}

static void Way_AutoLink( waypoint_t *wp )
{
	int wpidx = wp-waypoints;
	for (int i = 0i; i < iWaypoints; i++)
	{
		if (i == wpidx)
			continue;	//don't link to ourself...

		if (vlen(wp->org - waypoints[i].org) > autocvar( nav_linksize, 256, "Cuttoff distance between links" ) )
			continue;	//autolink distance cutoff.

		//not going to use the full player size because that makes steps really messy.
		//however, we do need a little size, for sanity's sake
		tracebox(wp->org, '-16 -16 0', '16 16 32', waypoints[i].org, TRUE, world);
		if (trace_fraction < 1)
			continue;	//light of sight blocked, don't try autolinking.
			
		Way_LinkWaypoints(wp, &waypoints[i]);
		Way_LinkWaypoints(&waypoints[i], wp);
	}
}

void Way_Waypoint_Create( entity pl, float autolink )
{
	vector pos = pl.origin;
	int idx = iWaypoints++;
	waypoints = memrealloc( waypoints, sizeof(waypoint_t), idx, iWaypoints );
	waypoint_t *n = waypoints + idx;
	n->org = pos;
	n->neighbour = __NULL__;
	n->iNeighbours = 0;
	
	if (autolink)
		Way_AutoLink(n);
}

void Way_Waypoint_Delete( int idx )
{
	if (idx < 0i || idx >= iWaypoints)
	{
		print("RT_DeleteWaypoint: invalid waypoint\n");
		return;
	}

	//wipe the waypoint
	memfree(waypoints[idx].neighbour);
	memcpy(waypoints+idx, waypoints+idx+1, (iWaypoints-(idx+1))*sizeof(*waypoints));
	iWaypoints--;

	//clean up any links to it.
	for (int i = 0; i < iWaypoints; i++)
	{
		for (int j = 0; j < waypoints[i].iNeighbours; )
		{
			int l = waypoints[i].neighbour[j].node;
			if (l == idx)
			{
				memcpy(waypoints[i].neighbour+j, waypoints[i].neighbour+j+1, (waypoints[i].iNeighbours-(j+1))*sizeof(*waypoints[i].neighbour));
				waypoints[i].iNeighbours--;
				continue;
			}
			else if (l > idx)
				waypoints[i].neighbour[j].node = l-1;
			j++;
		}
	}
}

void Way_Waypoint_SetRadius( int idx, float radius )
{
	if (idx < 0i || idx >= iWaypoints)
	{
		print("RT_Waypoint_SetRadius: invalid waypoint\n");
		return;
	}
	waypoints[idx].flRadius = radius;
}

void Way_Waypoint_MakeJump(int idx)
{
	if (idx < 0i || idx >= iWaypoints)
	{
		print("RT_Waypoint_SetRadius: invalid waypoint\n");
		return;
	}

	for(int j = 0i; j < waypoints[idx].iNeighbours; j++) {
		int target = waypoints[idx].neighbour[j].node;
		
		for(int b = 0i; b < waypoints[target].iNeighbours; b++) {
			if ( waypoints[target].neighbour[b].node == idx ) {
				waypoints[target].neighbour[b].iFlags = WP_JUMP;
			}
		}
	}
}

//-1 for no nodes anywhere...
int Way_FindClosestWaypoint( vector org )
{
	int r = -1i;
	float bestdist = COST_INFINITE;
	for (int i = 0i; i < iWaypoints; i++)
	{
		float dist = vlen(waypoints[i].org - org) - waypoints[i].flRadius;
		if (dist < bestdist)
		{
			if (dist < 0)
			{	//within the waypoint's radius
				bestdist = dist;
				r = i;
			}
			else
			{	//outside the waypoint, make sure its valid.
				traceline(org, waypoints[i].org, TRUE, world);
				if (trace_fraction == 1)
				{	//FIXME: sort them frst, to avoid traces?
					bestdist = dist;
					r = i;
				}
			}
		}
	}
	return r;
}

//Lame visualisation stuff - this is only visible on listen servers.
void SV_AddDebugPolygons( void ) {
	if ( !autocvar( way_display, 0, "Display current waypoints" ) ) {
		return;
	}

	if ( !iWaypoints ) {
		return;
	}

	int nearest = Way_FindClosestWaypoint(self.origin);
	makevectors(self.v_angle);
	R_BeginPolygon( "waypoint", 0, 0 );
	
	for ( int i = 0i; i < iWaypoints; i++ ) {
		waypoint_t *w = waypoints+i;
		vector org = w->org;
		vector rgb = '1 1 1';
		if (nearest == i)
			rgb = '0 1 0';
		R_PolygonVertex(org + v_right*16 - v_up*16, '1 1', rgb, 1);
		R_PolygonVertex(org - v_right*16 - v_up*16, '0 1', rgb, 1);
		R_PolygonVertex(org - v_right*16 + v_up*16, '0 0', rgb, 1);
		R_PolygonVertex(org + v_right*16 + v_up*16, '1 0', rgb, 1);
		R_EndPolygon();
	}
	
	R_BeginPolygon("", 0, 0);
	for ( int i = 0i; i < iWaypoints; i++ ) {
		waypoint_t *w = waypoints+i;
		vector org = w->org;
		
		for (float j = 0; j < 2*M_PI; j += 2*M_PI/4)
			R_PolygonVertex(org + [sin(j), cos(j)]*w->flRadius, '1 1', '0 0.25 0', 1);
		R_EndPolygon();
	}

	R_BeginPolygon("", 1, 0);
	for ( int i = 0i; i < iWaypoints; i++ ) {
		waypoint_t *w = waypoints+i;
		vector org = w->org;
		vector rgb = '1 1 1';
		for ( int j = 0i; j < w->iNeighbours; j++ ) {
			int k = w->neighbour[j].node;
			if ( k < 0i || k >= iWaypoints ) {
				break;
			}
			waypoint_t *w2 = &waypoints[k];
			R_PolygonVertex(org, '0 1', '1 0 1', 1);
			R_PolygonVertex(w2->org, '1 1', '0 1 0', 1);
			R_EndPolygon();
		}
	}
} 
