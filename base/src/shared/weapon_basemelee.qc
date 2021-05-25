enum
{
	MELEE_FAILED,
	MELEE_MISS,
	MELEE_HIT,
	MELEE_HITBODY
};

int
w_basemelee_fire(int d, int w)
{
	int anim = 0;
	vector src;
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		return (MELEE_FAILED);
	}

	Weapons_MakeVectors();
	src = pl.origin + pl.view_ofs;

	/* make sure we can gib corpses */
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE;
	traceline(src, src + (v_forward * 32), FALSE, pl);
	self.hitcontentsmaski = oldhitcontents;

	pl.w_attack_next = 0.5f;
	pl.w_idle_next = 2.5f;

	if (trace_fraction >= 1.0) {
		return (MELEE_MISS);
	}

#ifdef SERVER
	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, pl, d, w, DMG_BLUNT);
	}
#endif

	return (MELEE_HIT);
} 
