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

#define movevars_stepheight 22
#define movevars_friction 4
#define movevars_gravity 800
#define movevars_accelerate 10
#define movevars_stopspeed 100
#define movevars_maxspeed 320
#define movevars_jumpheight 270

.float pmove_flags;
.float gravity;

enumflags {
	PMF_JUMP_HELD,
	PMF_RESERVED,
	PMF_ONGROUND
};

static void dotouch( entity tother ) {
	entity oself;
	if (tother.touch == __NULL__)
		return;

	oself = self;
	other = self;
	self = tother;
	self.touch();
	self = oself;
}

void PhysicsMove_Rebound(vector surfnorm) {
	float v;
	v = self.velocity*surfnorm;
	self.velocity = self.velocity - surfnorm*(v);
}

//move forwards (preferably on the level) (does step ups)
void PhysicsMove_Move(void) {
	vector dest;
	vector saved_plane_normal;
	float stepped;
	float movetime;
	float attempts;

	//we need to bounce off surfaces (in order to slide along them), so we need at 2 attempts
	for (attempts = 3, movetime = input_timelength; movetime>0 && attempts; attempts--)
	{
		dest = self.origin + self.velocity*movetime;
		tracebox(self.origin, self.mins, self.maxs, dest, FALSE, self);	//try going straight there
		self.origin = trace_endpos;

		if (trace_fraction < 1)
		{
			saved_plane_normal = trace_plane_normal;

			movetime -= movetime * trace_fraction;

			if (movetime)
			{
				//step up if we can
				trace_endpos = self.origin;
				trace_endpos_z += movevars_stepheight;
				tracebox( self.origin, self.mins, self.maxs, trace_endpos, FALSE, self );
				stepped = trace_endpos_z - self.origin_z;

				dest = trace_endpos + self.velocity*movetime;
				dest_z = trace_endpos_z;
				//move forwards
				tracebox(trace_endpos, self.mins, self.maxs, dest, FALSE, self);

				//if we got anywhere, make this raised-step move count
				if (trace_fraction != 0)
				{
					if (trace_fraction < 1)
						PhysicsMove_Rebound(trace_plane_normal);

					//move down
					dest = trace_endpos;
					dest_z -= stepped+1;
					tracebox(trace_endpos, self.mins, self.maxs, dest, FALSE, self);
					if (trace_fraction < 1)
						PhysicsMove_Rebound(trace_plane_normal);

					self.origin = trace_endpos;

					movetime -= movetime * input_timelength;

					continue;
				}
			}
			
			//stepping failed, just bounce off
			PhysicsMove_Rebound(saved_plane_normal);

			dotouch(trace_ent);
		}
		else
			break;
	}
}
/*
void(vector dest) PhysicsMove_StepMove =
{
	//we hit something...

	//step up
	src = trace_endpos;
	trace_endpos_z += movevars_stepheight;
	tracebox(src, self.mins, self.maxs, dest, FALSE, self);
	stepped = trace_endpos_z - src_z;
	dest_z += stepped;

	//move forwards
	tracebox(trace_endpos, self.mins, self.maxs, dest, FALSE, self);

	//move down
	dest_z -= stepped;
	tracebox(trace_endpos, self.mins, self.maxs, dest, FALSE, self);
}
*/
void PhysicsMove_ApplyFriction( void ) {
	float newspeed, oldspeed;
	oldspeed = vlen(self.velocity);
	if (oldspeed < 1)
	{
		self.velocity = '0 0 0';
		return;
	}
	
	//calculate what their new speed should be
	newspeed = oldspeed - oldspeed*movevars_friction*input_timelength;

	//and slow them
	if (newspeed < 0)
		newspeed = 0;
	self.velocity = self.velocity * (newspeed/oldspeed);
}

void PhysicsMove_Accelerate(vector wishdir, float wishspeed, float accel) {
	float addspeed, accelspeed;
	float d;
	d = self.velocity*wishdir;
	addspeed = wishspeed - (d);
	if (addspeed <= 0)
		return;
	accelspeed = accel*input_timelength*wishspeed;
	if (accelspeed > addspeed)
		accelspeed = addspeed;

	self.velocity = self.velocity + accelspeed*wishdir;
}

void PhysicsMove_InAirAccelerate( void ) {
	vector hforward;
	vector hright;
	vector desireddir;
	float desiredspeed;

	hforward = v_forward;
	hforward_z = 0;
	hforward = normalize(hforward);
	hright = v_right;
	hright_z = 0;
	hright = normalize(hright);

	desireddir = hforward*input_movevalues_x + hright*input_movevalues_y;
	desiredspeed = vlen(desireddir);
	desireddir = normalize(desireddir);

	if (desiredspeed > movevars_maxspeed)
		desiredspeed = movevars_maxspeed;

	if (self.pmove_flags & PMF_ONGROUND)
	{
		if (input_buttons & 2)
		{
			if (!(self.pmove_flags & PMF_JUMP_HELD))
			{
				self.velocity_z += movevars_jumpheight;
				self.pmove_flags (+) PMF_ONGROUND;
			}
		}
	}

	if (self.pmove_flags & PMF_ONGROUND)
	{
		PhysicsMove_ApplyFriction();
		PhysicsMove_Accelerate(desireddir, desiredspeed, movevars_accelerate);
	}
	else
	{
		//there's no friction in air...
		if (desiredspeed > 30)
			desiredspeed = 30;
		PhysicsMove_Accelerate(desireddir, desiredspeed, movevars_accelerate);

		if (self.gravity)
			self.velocity_z -= self.gravity * movevars_gravity * input_timelength;
		else
			self.velocity_z -= movevars_gravity * input_timelength;
	}
}

void PhysicsMove_NoclipAccelerate( void ) {
	vector desireddir;
	float desiredspeed;

	desireddir = v_forward*input_movevalues_x + v_right*input_movevalues_y+v_up*input_movevalues_z;
	desiredspeed = vlen(desireddir);
	desireddir = normalize(desireddir);

	PhysicsMove_ApplyFriction();
	PhysicsMove_Accelerate(desireddir, desiredspeed, movevars_accelerate);
}

void PhysicsMove_Categorise( void ) {
	//if we're moving up, we're not on the ground
	if (self.velocity_z > 0)
		self.pmove_flags (-) PMF_ONGROUND;
	else
	{
		//don't know, maybe we are, maybe we're not
		tracebox(self.origin, self.mins, self.maxs, self.origin-'0 0 1', FALSE, self);
		if (trace_fraction == 1 || trace_plane_normal_z < 0.7) {
			self.pmove_flags (-) PMF_ONGROUND;
//			self.groundentity = trace_ent;
		}
		else
			self.pmove_flags (+) PMF_ONGROUND;
	}
}

void PhysicsMove( entity eEnt ) {
	self = eEnt;
	makevectors(input_angles);

	if (!(input_buttons & PMF_JUMP_HELD))
		self.pmove_flags (-) PMF_JUMP_HELD;

	PhysicsMove_Categorise();
	
	switch ( self.movetype ) {
	case MOVETYPE_WALK:
		PhysicsMove_InAirAccelerate();
		PhysicsMove_Move();
		break;
	case MOVETYPE_FLY:
		PhysicsMove_NoclipAccelerate();
		PhysicsMove_Move();
		break;
	case MOVETYPE_NOCLIP:
		PhysicsMove_NoclipAccelerate();
		self.origin += self.velocity*input_timelength;
		break;
	case MOVETYPE_NONE:
		break;
	}
}
