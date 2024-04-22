/*
 * Copyright (c) 2016-2023 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

/* TODO: needs to be made consistent across all entities. */
void
Entity_EntityUpdate(float type, float new)
{
	switch (type) {
	case ENT_ENTITY:
		NSENTITY_READENTITY(NSEntity, new)
		break;
	case ENT_PMOVEVARS:
		NSENTITY_READENTITY(NSPMoveVars, new)
		break;
	case ENT_ENTITYRENDERABLE:
		NSENTITY_READENTITY(NSRenderableEntity, new)
		break;
	case ENT_SURFPROP:
		NSENTITY_READENTITY(NSSurfacePropEntity, new)
		break;
	case ENT_BEAM:
		NSENTITY_READENTITY(env_beam, new)
		break;
	case ENT_FUNNEL:
		NSENTITY_READENTITY(env_funnel, new)
		break;
	case ENT_SMOKER:
		NSENTITY_READENTITY(env_smoker, new)
		break;
	case ENT_LASER:
		NSENTITY_READENTITY(env_laser, new)
		break;
	case ENT_PHYSICS:
		NSENTITY_READENTITY(NSPhysicsEntity, new)
		break;
	case ENT_MONSTER:
		NSENTITY_READENTITY(NSMonster, new)
		self.customphysics = Empty;
		break;
	case ENT_TALKMONSTER:
		NSENTITY_READENTITY(NSTalkMonster, new)
		self.customphysics = Empty;
		break;
	case ENT_SPEAKER:
		NSENTITY_READENTITY(speaker, new)
		self.customphysics = Empty;
		break;
	case ENT_TRACKTRAIN:
		NSENTITY_READENTITY(func_tracktrain, new)
		break;
	case ENT_VEHICLE:
		NSENTITY_READENTITY(NSVehicle, new)
		break;
	case ENT_PORTAL:
		NSENTITY_READENTITY(NSPortal, new)
		break;
	case ENT_VEH_BRUSH:
		NSENTITY_READENTITY(func_vehicle, new)
		break;
	case ENT_VEH_TANKMORTAR:
		NSENTITY_READENTITY(func_tankmortar, new)
		break;
	case ENT_VEH_4WHEEL:
		NSENTITY_READENTITY(prop_vehicle_driveable, new)
		break;
	case ENT_PLAYER:
		NSClientPlayer pl = (NSClientPlayer)self;

		/* splitscreen */
		CSQC_UpdateSeat();
		self.customphysics = Empty;

		Predict_EntityUpdate(pl, new);

		/* any differences in things that are read below are now
		   officially from prediction misses. */
		float a = readfloat();
		pl.ReceiveEntity(new, a);
		break;
	case ENT_SPECTATOR:
		Spectator_ReadEntity(new);
		break;
	case ENT_SPRITE:
		NSENTITY_READENTITY(env_sprite, new)
		break;
	case ENT_GLOW:
		NSENTITY_READENTITY(env_glow, new)
		break;
	case ENT_SPRAY:
		Spray_Parse();
		break;
	case ENT_DECAL:
		Decal_Parse();
		break;
	case ENT_AMBIENTSOUND:
		NSENTITY_READENTITY(ambient_generic, new)
		break;
	case ENT_OLDCAMERA:
		NSENTITY_READENTITY(trigger_camera, new)
		break;
	case ENT_MONITOR:
		NSENTITY_READENTITY(func_monitor, new)
		break;
	case ENT_DLIGHT:
		NSENTITY_READENTITY(light_dynamic, new)
		break;
	case ENT_PROJECTEDTEXTURE:
		NSENTITY_READENTITY(env_projectedtexture, new)
		break;
	case ENT_SPOTLIGHT:
		NSENTITY_READENTITY(point_spotlight, new)
		break;
	case ENT_FOG:
		NSENTITY_READENTITY(env_fog, new)
		break;
	case ENT_STEAM:
		NSENTITY_READENTITY(env_steam, new)
		break;
	case ENT_FOGCONTROLLER:
		NSENTITY_READENTITY(env_fog_controller, new)
		break;
	case ENT_CASCADELIGHT:
		NSENTITY_READENTITY(env_cascade_light, new)
		break;
	case ENT_PARTSYSTEM:
		NSENTITY_READENTITY(info_particle_system, new)
		break;
	case ENT_PROPROPE:
		NSENTITY_READENTITY(prop_rope, new)
		break;
	case ENT_PHYSROPE:
		NSENTITY_READENTITY(phys_rope, new)
		break;
	case ENT_BUBBLES:
		NSENTITY_READENTITY(env_bubbles, new)
		break;
	case ENT_CONVEYOR:
		NSENTITY_READENTITY(func_conveyor, new)
		break;
	case ENT_WAYPOINT:
		NSENTITY_READENTITY(info_waypoint, new)
		break;
	case ENT_INSTRUCTOR:
		NSENTITY_READENTITY(env_instructor_hint, new)
		break;
	case ENT_PUSH:
		NSENTITY_READENTITY(trigger_push, new)
		break;
	case ENT_ENTITYPROJECTILE:
		NSENTITY_READENTITY(NSProjectile, new)
		break;
	default:
			//error(sprintf("Unknown entity type update received. (%d)\n", t));
	}
}

float
Entities_ParseLump(void)
{
	entity eOld;
	NSEntity eEnt = __NULL__;
	string strField, strValue;
	__fullspawndata = "";
	int iClass = FALSE;

	eOld = self;

	while (1) {
		strField = getentitytoken();

		if (!strField) {
			break;
		}

		if (strField == "}") {
			/* invalid entity */
			if (!eEnt.classname) {
				break;
			}

			__fullspawndata = "";

			/* remove if we've found no valid class to go with us */
			if (eEnt && eEnt.isCSQC == false) {
				remove(eEnt);
			}

			if (eEnt.identity)
			if (eEnt.CanSpawn(true) == false)
				eEnt.Destroy();

			return (1);
		}

		strValue = getentitytoken();
		if (!strValue) {
			break;
		}

		switch (strField) {
		case "classname":
			eEnt = (NSEntity)spawn();

			/* check if our classname has a matching class */
			if (isfunction(strcat("spawnfunc_", strValue))) {
				self = eEnt;
				self._mapspawned = true;
				callfunction(strcat("spawnfunc_", strValue));
				self = eOld;
				iClass = TRUE;
			} else {
				eEnt.classname = strValue;
			}
			break;
		default:
			__fullspawndata = sprintf("%s\"%s\" \"%s\" ",
				__fullspawndata, strField, strValue);
			break;
		}
	}

	return (0);
}

void
Entities_RendererRestarted(void)
{
	int c = 0;

	for (entity b = world; (b = findfloat(b, ::isCSQC, TRUE));) {
		NSEntity pf = (NSEntity) b;
		pf.RendererRestarted();
		c++;
	}

	NSLog("...resource reload called on %i entities", c);
}
