/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#ifdef CSQC

string g_hgibs[] = {
	"models/gib_b_bone.mdl",
	"models/gib_legbone.mdl",
	"models/gib_lung.mdl",
	"models/gib_skull.mdl",
	"models/gib_b_gib.mdl"
};

void Effects_Init(void)
{
	precache_model("sprites/fexplo.spr");
	precache_model("sprites/bloodspray.spr");
	precache_model("sprites/blood.spr");
	precache_model("models/glassgibs.mdl");
	precache_model("models/woodgibs.mdl");
	precache_model("models/metalplategibs.mdl");
	precache_model("models/fleshgibs.mdl");
	precache_model("models/ceilinggibs.mdl");
	precache_model("models/computergibs.mdl");
	precache_model("models/rockgibs.mdl");
	precache_model("models/cindergibs.mdl");
	
	precache_sound("debris/bustglass1.wav");
	precache_sound("debris/bustglass2.wav");
	precache_sound("debris/bustglass3.wav");
	precache_sound("debris/bustcrate1.wav");
	precache_sound("debris/bustcrate2.wav");
	precache_sound("debris/bustcrate3.wav");
	precache_sound("debris/bustmetal1.wav");
	precache_sound("debris/bustmetal2.wav");
	precache_sound("debris/bustflesh1.wav");
	precache_sound("debris/bustflesh2.wav");
	precache_sound("debris/bustconcrete1.wav");
	precache_sound("debris/bustconcrete2.wav");
	precache_sound("debris/bustceiling.wav");
	precache_sound("weapons/explode3.wav");
	precache_sound("weapons/explode4.wav");
	precache_sound("weapons/explode5.wav");
	precache_sound("buttons/spark1.wav");
	precache_sound("buttons/spark2.wav");
	precache_sound("buttons/spark3.wav");
	precache_sound("buttons/spark4.wav");
	precache_sound("buttons/spark5.wav");
	precache_sound("buttons/spark6.wav");
	precache_sound("weapons/knife_hitwall1.wav");
	precache_sound("weapons/ric1.wav");
	precache_sound("weapons/ric2.wav");
	precache_sound("weapons/ric3.wav");
	precache_sound("weapons/ric4.wav");
	precache_sound("weapons/ric5.wav");
	precache_sound("common/bodysplat.wav");

	for (int i = 0; i < g_hgibs.length; i++) {
		precache_model(g_hgibs[i]);
	}

	// Half-Life only has generic ric1-5
#ifdef CSTRIKE
	precache_sound("weapons/ric_metal-1.wav");
	precache_sound("weapons/ric_metal-2.wav");
	precache_sound("weapons/ric_conc-1.wav");
	precache_sound("weapons/ric_conc-2.wav");
#endif

}
#endif


void Effect_GibHuman(vector pos) {
#ifdef SSQC
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_GIBHUMAN);
	WriteCoord(MSG_MULTICAST, pos[0]); 
	WriteCoord(MSG_MULTICAST, pos[1]); 
	WriteCoord(MSG_MULTICAST, pos[2]);
	msg_entity = __NULL__;
	multicast(pos, MULTICAST_PVS);
#else
	static void Gib_Remove(void) {
		remove(self);
	}
	for (int i = 0; i < 5; i++) {
		
		vector vel;
		vel[0] = random(-128,128);
		vel[1] = random(-128,128);
		vel[2] = (300 + random() * 64);
	
		entity gibb = spawn();
		setmodel(gibb, g_hgibs[i]);
		setorigin(gibb, pos);
		gibb.movetype = MOVETYPE_BOUNCE;
		gibb.velocity = vel;
		gibb.avelocity = vectoangles(gibb.velocity);
		gibb.think = Gib_Remove;
		gibb.nextthink = time + 5.0f;
		gibb.drawmask = MASK_ENGINE;
	}
	pointsound(pos, "common/bodysplat.wav", 1, ATTN_NORM);
#endif
}

void Effect_CreateExplosion(vector vPos) {
#ifdef SSQC
	Decals_PlaceScorch(vPos);
	vPos[2] += 48;
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_EXPLOSION);
	WriteCoord(MSG_MULTICAST, vPos[0]); 
	WriteCoord(MSG_MULTICAST, vPos[1]); 
	WriteCoord(MSG_MULTICAST, vPos[2]);
	msg_entity = self;
	multicast(vPos, MULTICAST_PVS);
#else
	sprite eExplosion = spawn(sprite);
	setorigin(eExplosion, vPos);
	setmodel(eExplosion, "sprites/fexplo.spr");
	sound(eExplosion, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 3) + 3), 1, ATTN_NORM);

	//eExplosion.think = Effect_CreateExplosion_Animate;
	eExplosion.effects = EF_ADDITIVE;
	eExplosion.drawmask = MASK_ENGINE;
	eExplosion.maxframe = modelframecount(eExplosion.modelindex);
	eExplosion.loops = 0;
	eExplosion.framerate = 20;
	eExplosion.nextthink = time + 0.05f;

	te_explosion(vPos);
#endif
}

void Effect_CreateBlood(vector vPos, vector vAngle) {
#ifdef SSQC
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_BLOOD);
	WriteCoord(MSG_MULTICAST, vPos[0]); 
	WriteCoord(MSG_MULTICAST, vPos[1]); 
	WriteCoord(MSG_MULTICAST, vPos[2]);
	WriteCoord(MSG_MULTICAST, vAngle[0]); 
	WriteCoord(MSG_MULTICAST, vAngle[1]); 
	WriteCoord(MSG_MULTICAST, vAngle[2]);
	msg_entity = self;
	multicast(vPos, MULTICAST_PVS);
#else
	sprite eBlood = spawn(sprite);
	setorigin(eBlood, vPos);
	setmodel(eBlood, "sprites/bloodspray.spr");

	//eExplosion.think = Effect_CreateExplosion_Animate;
	//eBlood.effects = EF_ADDITIVE;
	eBlood.drawmask = MASK_ENGINE;
	eBlood.maxframe = modelframecount(eBlood.modelindex);
	eBlood.loops = 0;
	eBlood.scale = 0.5f;
	eBlood.colormod = [1,0,0];
	eBlood.framerate = 20;
	eBlood.nextthink = time + 0.05f;
	
	for (int i = 0; i < 3; i++) {
		sprite ePart = spawn(sprite);
		setorigin(ePart, vPos);
		setmodel(ePart, "sprites/blood.spr");
		ePart.movetype = MOVETYPE_BOUNCE;
		ePart.gravity = 0.5f;
		ePart.scale = 0.5f;
		ePart.drawmask = MASK_ENGINE;
		ePart.maxframe = modelframecount(ePart.modelindex);
		ePart.loops = 0;
		ePart.colormod = [1,0,0];
		ePart.framerate = 15;
		ePart.nextthink = time + 0.1f;
		ePart.velocity = randomvec() * 64;
	}
#endif
}

void Effect_CreateSpark(vector vPos, vector vAngle) {
#ifdef SSQC
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SPARK);
	WriteCoord(MSG_MULTICAST, vPos[0]); 
	WriteCoord(MSG_MULTICAST, vPos[1]); 
	WriteCoord(MSG_MULTICAST, vPos[2]);
	WriteCoord(MSG_MULTICAST, vAngle[0]); 
	WriteCoord(MSG_MULTICAST, vAngle[1]); 
	WriteCoord(MSG_MULTICAST, vAngle[2]);
	msg_entity = self;
	multicast(vPos, MULTICAST_PVS);
#else
	pointparticles(PARTICLE_SPARK, vPos, vAngle, 1);
	pointsound(vPos, sprintf("buttons/spark%d.wav", floor(random() * 6) + 1), 1, ATTN_STATIC);
#endif
}

#ifdef CSTRIKE
#ifdef SSQC
void Effect_CreateFlash(entity eTarget) {
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_FLASH);
	msg_entity = eTarget;
	multicast([0,0,0], MULTICAST_ONE);
}
#endif
#endif

#ifdef CSTRIKE
void Effect_CreateSmoke(vector vPos) {
#ifdef SSQC
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SMOKE);
	WriteCoord(MSG_MULTICAST, vPos[0]); 
	WriteCoord(MSG_MULTICAST, vPos[1]); 
	WriteCoord(MSG_MULTICAST, vPos[2]);
	msg_entity = self;
	multicast([0,0,0], MULTICAST_ALL);
#else
	static void Effect_CreateSmoke_Think(void) {
		// HACK: This should only ever happen when rounds restart!
		// Any way this can go wrong?
		if (self.skin < getstatf(STAT_GAMETIME)) {
			remove(self);
		}
		if (self.frame <= 0) {
			remove(self);
			return;
		} 
	
		pointparticles(PARTICLE_SMOKEGRENADE, self.origin, [0,0,0], 1);
		self.frame--;
		self.nextthink = time + 0.2f;
		self.skin = getstatf(STAT_GAMETIME);
	}
	
	entity eSmoke = spawn();
	setorigin(eSmoke, vPos);
	eSmoke.think = Effect_CreateSmoke_Think;
	eSmoke.nextthink = time;
	eSmoke.frame = 200;
	eSmoke.skin = getstatf(STAT_GAMETIME);
#endif
}
#endif

void Effect_Impact(int iType, vector vPos, vector vNormal) {
#ifdef SSQC
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_IMPACT);
	WriteByte(MSG_MULTICAST, (float)iType);
	WriteCoord(MSG_MULTICAST, vPos[0]); 
	WriteCoord(MSG_MULTICAST, vPos[1]); 
	WriteCoord(MSG_MULTICAST, vPos[2]);
	WriteCoord(MSG_MULTICAST, vNormal[0]); 
	WriteCoord(MSG_MULTICAST, vNormal[1]); 
	WriteCoord(MSG_MULTICAST, vNormal[2]);
	msg_entity = self;
	multicast(vPos, MULTICAST_PVS);
	
	switch (iType) {
		case IMPACT_GLASS:
			Decals_PlaceGlass(vPos);
			break;
		case IMPACT_MELEE:
			Decals_PlaceSmall(vPos);
			break;
		default:
			Decals_PlaceBig(vPos);
			break;
	}
#else
	switch (iType) {
		case IMPACT_MELEE:
			/*pointparticles(DECAL_SHOT, vPos, vNormal, 1);
			pointparticles(PARTICLE_PIECES_BLACK, vPos, vNormal, 1);*/
			pointsound(vPos, "weapons/knife_hitwall1.wav", 1, ATTN_STATIC);
			//Decals_PlaceSmall(vPos);
			break;
		case IMPACT_EXPLOSION:
			break;
		case IMPACT_GLASS:
			//pointparticles(DECAL_GLASS, vPos, vNormal, 1);
			pointparticles(PARTICLE_PIECES_BLACK, vPos, vNormal, 1);
			//Decals_PlaceBig(vPos);
			break;
		case IMPACT_WOOD:
			//pointparticles(DECAL_SHOT, vPos, vNormal, 1);
			pointparticles(PARTICLE_SPARK, vPos, vNormal, 1);
			pointparticles(PARTICLE_PIECES_BLACK, vPos, vNormal, 1);
			pointparticles(PARTICLE_SMOKE_BROWN, vPos, vNormal, 1);
			//Decals_PlaceBig(vPos);
			break;
		case IMPACT_METAL:
			//pointparticles(DECAL_SHOT, vPos, vNormal, 1);
			pointparticles(PARTICLE_SPARK, vPos, vNormal, 1);
			pointparticles(PARTICLE_SPARK, vPos, vNormal, 1);
			pointparticles(PARTICLE_PIECES_BLACK, vPos, vNormal, 1);
			//Decals_PlaceBig(vPos);
			break;
		case IMPACT_FLESH:
			pointparticles(PARTICLE_BLOOD, vPos, vNormal, 1);
			//Decals_PlaceBig(vPos);
			break;
		case IMPACT_DEFAULT:
			//pointparticles(DECAL_SHOT, vPos, vNormal, 1);
			pointparticles(PARTICLE_SPARK, vPos, vNormal, 1);
			pointparticles(PARTICLE_PIECES_BLACK, vPos, vNormal, 1);
			pointparticles(PARTICLE_SMOKE_GREY, vPos, vNormal, 1);
			//Decals_PlaceBig(vPos);
			break;
		default:
	}
	
	switch (iType) {
#ifdef CSTRIKE
		case IMPACT_METAL:
			pointsound(vPos, sprintf("weapons/ric_metal-%d.wav", floor((random() * 2) + 1)), 1, ATTN_STATIC);
			break;
		case IMPACT_ROCK:
			pointsound(vPos, sprintf("weapons/ric_conc-%d.wav", floor((random() * 2) + 1)), 1, ATTN_STATIC);
			break;
#endif
		case IMPACT_FLESH:
			break;
		default:
			pointsound(vPos, sprintf("weapons/ric%d.wav", floor((random() * 5) + 1)), 1, ATTN_STATIC);
			break;
	}
	
#endif
}

void Effect_BreakModel(int count, vector vMins, vector vMaxs, vector vVel, float fStyle) {
#ifdef SSQC
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MODELGIB);
	WriteCoord(MSG_MULTICAST, vMins[0]); 
	WriteCoord(MSG_MULTICAST, vMins[1]); 
	WriteCoord(MSG_MULTICAST, vMins[2]);
	WriteCoord(MSG_MULTICAST, vMaxs[0]); 
	WriteCoord(MSG_MULTICAST, vMaxs[1]); 
	WriteCoord(MSG_MULTICAST, vMaxs[2]);
	WriteByte(MSG_MULTICAST, fStyle);
	WriteByte(MSG_MULTICAST, count);

	msg_entity = self;
	
	vector vWorldPos;
	vWorldPos[0] = vMins[0] + (0.5 * (vMaxs[0] - vMins[0]));	
	vWorldPos[1] = vMins[1] + (0.5 * (vMaxs[1] - vMins[1]));	
	vWorldPos[2] = vMins[2] + (0.5 * (vMaxs[2] - vMins[2]));
	multicast(vWorldPos, MULTICAST_PVS);
#else
	static void Effect_BreakModel_Remove(void) { remove(self) ; }

	float fModelCount;
	vector vPos;
	string sModel = "";
	float fCount = 20;
	
	switch (fStyle) {
		case MATERIAL_GLASS:
		case MATERIAL_GLASS_UNBREAKABLE:
			sModel = "models/glassgibs.mdl";
			fModelCount = 8;
			break;
		case MATERIAL_WOOD:
			sModel = "models/woodgibs.mdl";
			fModelCount = 3;
			break;
		case MATERIAL_METAL:
			sModel = "models/metalplategibs.mdl";
			fModelCount = 13;
			break;
		case MATERIAL_FLESH:
			sModel = "models/fleshgibs.mdl";
			fModelCount = 4;
			break;
		case MATERIAL_TILE:
			sModel = "models/ceilinggibs.mdl";
			fModelCount = 4;
			break;
		case MATERIAL_COMPUTER:
			sModel = "models/computergibs.mdl";
			fModelCount = 15;
			break;
		case MATERIAL_ROCK:
			sModel = "models/rockgibs.mdl";
			fModelCount = 3;
			break;
		default:
		case MATERIAL_CINDER:
			sModel = "models/cindergibs.mdl";
			fModelCount = 9;
			break;
	}
	
	vector vWorldPos;
	vWorldPos[0] = vMins[0] + (0.5 * (vMaxs[0] - vMins[0]));	
	vWorldPos[1] = vMins[1] + (0.5 * (vMaxs[1] - vMins[1]));	
	vWorldPos[2] = vMins[2] + (0.5 * (vMaxs[2] - vMins[2]));
	
	switch (fStyle) {
		case MATERIAL_GLASS:
			pointsound(vWorldPos, sprintf("debris/bustglass%d.wav", random(1, 4)), 1.0f, ATTN_NORM);
			break;
		case MATERIAL_WOOD:
			pointsound(vWorldPos, sprintf("debris/bustcrate%d.wav", random(1, 4)), 1.0f, ATTN_NORM);
			break;
		case MATERIAL_METAL:
		case MATERIAL_COMPUTER:
			pointsound(vWorldPos, sprintf("debris/bustmetal%d.wav", random(1, 3)), 1.0f, ATTN_NORM);
			break;
		case MATERIAL_FLESH:
			pointsound(vWorldPos, sprintf("debris/bustflesh%d.wav", random(1, 3)), 1.0f, ATTN_NORM);
			break;
		case MATERIAL_CINDER:
		case MATERIAL_ROCK:
			pointsound(vWorldPos, sprintf("debris/bustconcrete%d.wav", random(1, 4)), 1.0f, ATTN_NORM);
			break;
		case MATERIAL_TILE:
			pointsound(vWorldPos, "debris/bustceiling.wav", 1.0f, ATTN_NORM);
			break;
	}
	
	while (fCount > 0) {
		entity eGib = spawn();
		eGib.classname = "gib";
		
		vPos[0] = vMins[0] + (random() * (vMaxs[0] - vMins[0]));	
		vPos[1] = vMins[1] + (random() * (vMaxs[1] - vMins[1]));	
		vPos[2] = vMins[2] + (random() * (vMaxs[2] - vMins[2]));	
		
		setorigin(eGib, vPos);
		setmodel(eGib, sModel);
		setcustomskin(eGib, "", sprintf("geomset 0 %f\n", random(1, fModelCount + 1)));
		eGib.movetype = MOVETYPE_BOUNCE;
		eGib.solid = SOLID_NOT;
		
		eGib.avelocity[0] = random()*600;
		eGib.avelocity[1] = random()*600;
		eGib.avelocity[2] = random()*600;
		eGib.think = Effect_BreakModel_Remove;
		eGib.nextthink = time + 10;
		
		if ((fStyle == MATERIAL_GLASS) || (fStyle == MATERIAL_GLASS_UNBREAKABLE)) {
			eGib.effects = EF_ADDITIVE;
			eGib.alpha = 0.3;
		}
		
		fCount--;
		eGib.drawmask = MASK_ENGINE;
	}
#endif
}
