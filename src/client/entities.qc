/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
		NSEntity_ReadEntity(new);
		break;
	case ENT_ENTITYRENDERABLE:
		NSRenderableEntity_ReadEntity(new);
		break;
	case ENT_SURFPROP:
		NSSurfacePropEntity_ReadEntity(new);
		break;
	case ENT_BEAM:
		env_beam_ReadEntity(new);
		break;
	case ENT_LASER:
		env_laser_ReadEntity(new);
		break;
	case ENT_PHYSICS:
		NSPhysicsEntity_ReadEntity(new);
		break;
	case ENT_MONSTER:
		NSMonster_ReadEntity(new);
		self.customphysics = Empty;
		break;
	case ENT_TALKMONSTER:
		NSTalkMonster_ReadEntity(new);
		self.customphysics = Empty;
		break;
	case ENT_VEHICLE:
		basevehicle_readentity(new);
		break;
	case ENT_PORTAL:
		NSPortal_ReadEntity(new);
		break;
	case ENT_VEH_BRUSH:
		func_vehicle_readentity(new);
		break;
	case ENT_VEH_TANKMORTAR:
		func_tankmortar_readentity(new);
		break;
	case ENT_VEH_4WHEEL:
		prop_vehicle_driveable_readentity(new);
		break;
	case ENT_PLAYER:
		player pl = (player)self;

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
		env_sprite spr = (env_sprite)self;
		if (new) {
			spawnfunc_env_sprite();
		}
		spr.ReceiveEntity(new, readfloat());
		break;
	case ENT_SPRAY:
		Spray_Parse();
		break;
	case ENT_DECAL:
		Decal_Parse();
		break;
	case ENT_AMBIENTSOUND:
		ambient_generic_ReadEntity(new);
		break;
	case ENT_OLDCAMERA:
		trigger_camera tc = (trigger_camera)self;
		if (new) {
			spawnfunc_trigger_camera();
		}
		tc.ReceiveEntity(new, readfloat());
		break;
	case ENT_MONITOR:
		func_monitor fc = (func_monitor)self;
		if (new) {
			spawnfunc_func_monitor();
		}
		fc.ReceiveEntity(new, readfloat());
		break;
	case ENT_DLIGHT:
		light_dynamic_ReadEntity(new);
		break;
	case ENT_PROJECTEDTEXTURE:
		env_projectedtexture ept = (env_projectedtexture)self;
		if (new) {
			spawnfunc_env_projectedtexture();
		}
		ept.ReceiveEntity(new, readfloat());
		break;
	case ENT_SPOTLIGHT:
		point_spotlight_ReadEntity(new);
		break;
	case ENT_FOG:
		env_fog_readentity(new);
		break;
	case ENT_STEAM:
		env_steam_ReadEntity(new);
		break;
	case ENT_FOGCONTROLLER:
		env_fog_controller_readentity(new);
		break;
	case ENT_PARTSYSTEM:
		info_particle_system ips = (info_particle_system)self;
		if (new) {
			spawnfunc_info_particle_system();
		}
		ips.ReceiveEntity(new, readfloat());
		break;
	case ENT_PROPROPE:
		prop_rope_readentity(new);
		break;
	case ENT_BUBBLES:
		env_bubbles_ReadEntity(new);
		break;
	case ENT_CONVEYOR:
		func_conveyor_ReadEntity(new);
		break;
	case ENT_WAYPOINT:
		info_waypoint_ReadEntity(new);
		break;
	case ENT_PUSH:
		trigger_push_ReadEntity(new);
		break;
	case ENT_ENTITYPROJECTILE:
		NSProjectile_ReadEntity(new);
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
	print("--------- Reloading Entity Resources ----------\n");

	for (entity b = world; (b = findfloat(b, ::isCSQC, TRUE));) {
		NSEntity pf = (NSEntity) b;
		pf.RendererRestarted();
		c++;
	}

	print(sprintf("resource reload called on %i entities\n", c));
}
