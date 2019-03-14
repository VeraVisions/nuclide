/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/* This really shouldn't be here, but it'll be fine for the time being */
.int initedsci;
float Scientist_PreDraw(void)
{
	/* Only do this once whenever the ent pops into view */
	if (!self.initedsci) {
		setcustomskin(self, "", sprintf("geomset 1 %d\n", self.colormod[0]));
		self.initedsci = TRUE;
	}

	/* HACK: We're abusing this networked field, so reset */
	self.colormod = [0,0,0];
	addentity(self);
	return PREDRAW_NEXT;
}
float Scientist_Update(float new)
{
	if (new) {
		self.predraw = Scientist_PreDraw;
		self.drawmask = MASK_ENGINE;
	}
	return TRUE;
}

/*
=================
Client_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void Client_Init(float apilevel, string enginename, float engineversion)
{
	precache_model("sprites/640hud1.spr");
	precache_model("sprites/640hud2.spr");
	precache_model("sprites/640hud3.spr");
	precache_model("sprites/640hud4.spr");
	precache_model("sprites/640hud5.spr");
	precache_model("sprites/640hud6.spr");
	precache_model("sprites/chainsaw.spr");
	precache_model("sprites/hammer.spr");
	precache_model("sprites/w_cannon.spr");

	/* FIXME: Replace with manual networking once I've got time? */
	deltalisten("models/scientist.mdl", Scientist_Update, 0);
}

void Game_RendererRestarted(string rstr)
{
	
}
