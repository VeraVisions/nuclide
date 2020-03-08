/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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

/* the rocket launcher */

enum {
	DML_IDLE, // 2.5f
	DML_FIDGET, // 2.0f
	DML_RELOADBOTH, // 1.6f
	DML_RELOADLEFT, // 1.6f
	DML_RELOADRIGHT, // 1.6f
	DML_FIRE, // 1.222222f
	DML_CUSTOMIZE, // 4.0f
	DML_DRAW // 1.222222f
};

enum {
	DS_FULL,
	DS_RELOADING
};

enum {
	DMENU_NONE,
	DMENU_LAUNCH,
	DMENU_FLIGHTPATH,
	DMENU_DETONATE,
	DMENU_PAYLOAD
};

/* customizable states */
enum {
	LAUNCH_FIRED,
	LAUNCH_TARGETED
};

enum {
	FLIGHTPATH_GUIDED,
	FLIGHTPATH_HOMING,
	FLIGHTPATH_SPIRAL
} ;

enum {
	DETONATE_IMPACT,
	DETONATE_PROXIMITY,
	DETONATE_TIMED,
	DETONATE_TRIPPED
};

enum {
	PAYLOAD_EXPLOSIVE,
	PAYLOAD_CLUSTER
};

/* functions */
void
w_dml_draw(void)
{
	Weapons_SetModel("models/v_dml.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(DML_DRAW);
}

void
w_dml_holster(void)
{

}

void
w_dml_release(void)
{
	player pl = (player)self;
	pl.flags |= FL_SEMI_TOGGLED;
	if (pl.w_idle_next) {
		return;
	}
	
	if (pl.a_ammo3 == DS_RELOADING) {
		if (pl.a_ammo1 == 1) {
			Weapons_ViewAnimation(DML_RELOADRIGHT);
		} else {
			Weapons_ViewAnimation(DML_RELOADLEFT);
		}
		
		sound(pl, CHAN_WEAPON, "weapons/dml_reload.wav", 1.0f, ATTN_NORM);
		pl.w_attack_next = 1.6f;
		pl.w_idle_next = pl.w_attack_next;
		pl.a_ammo3 = DS_FULL;
		return;
	}

	int r  = (float)input_sequence % 5;
	switch (r) {
	case 0:
	case 1:
	case 2:
	case 3:
		Weapons_ViewAnimation(DML_IDLE);
		pl.w_idle_next = 10.0f;
		break;
	default:
		Weapons_ViewAnimation(DML_FIDGET);
		pl.w_idle_next = 2.0f;
	}
}

void
w_dml_primary(void)
{
	vector src;
	player pl = (player)self;

	if not (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

	if (pl.a_ammo1 > 0) {
		pl.a_ammo1 = 0;
		pl.flags &= ~FL_SEMI_TOGGLED;
		Weapons_ViewAnimation(DML_CUSTOMIZE);
		sound(pl, 8, "weapons/dml_customize.wav", 1.0f, ATTN_NORM);
		pl.w_attack_next = 4.0f;
		pl.w_idle_next = 5.0f;
		return;
	}

	if (pl.w_attack_next) {
		return;
	}

	if (pl.a_ammo3 == DS_RELOADING) {
		w_dml_release();
		return;
	}

	src = Weapons_GetCameraPos();

#ifdef SSQC
	sound(pl, CHAN_WEAPON, "weapons/dml_fire.wav", 1.0f, ATTN_NORM);
#endif

	Weapons_ViewAnimation(DML_FIRE);
	pl.w_attack_next = 1.222222f;
	pl.w_idle_next = 1.222222f;
	pl.a_ammo3 = DS_RELOADING;
}

void
w_dml_secondary(void)
{
	player pl = (player)self;

	if not (pl.flags & FL_SEMI_TOGGLED) {
		return;
	}

	pl.flags &= ~FL_SEMI_TOGGLED;

	if (pl.w_attack_next) {
		return;
	}

	/* activate menu */
	if (pl.a_ammo1 <= 0 || pl.a_ammo1 == DMENU_PAYLOAD) {
		pl.a_ammo1 = 1;
	} else {
		pl.a_ammo1 = bound(DMENU_LAUNCH, pl.a_ammo1 + 1, DMENU_PAYLOAD);
	}
}

void
w_dml_updateammo(player pl)
{
#ifdef SSQC
	Weapons_UpdateAmmo(pl, -1, pl.ammo_rockets, -1);
#endif
}

string
w_dml_wmodel(void)
{
	return "models/w_dml.mdl";
}

string
w_dml_pmodel(void)
{
	return "models/p_crossbow.mdl";
}

string
w_dml_deathmsg(void)
{
	return "";
}

float
w_dml_aimanim(void)
{
	return 0;
}

int
w_dml_pickup(int new)
{
#ifdef SSQC
	player pl = (player)self;

	if (pl.ammo_rocket < 100) {
		pl.ammo_rocket = bound(0, pl.ammo_rocket + 2, 100);
	} else {
		return FALSE;
	}
#endif
	return TRUE;
}

void
w_dml_hud(void)
{
#ifdef CSQC
	static string lmodes[] = {
		"WHEN FIRED",
		"WHEN TARGETED"
	};
	static string fmodes[] = {
		"GUIDED",
		"HOMING",
		"SPIRAL"
	};
	static string dmodes[] = {
		"ON IMPACT",
		"IN PROXIMITY",
		"TIMED",
		"WHEN TRIPPED"
	};
	static string pmodes[] = {
		"EXPLOSIVE",
		"CLUSTER"
	};
	vector pos;
	vector jitter;
	float lerp;
	player pl = (player)self;
	
	/* laser */
	Weapons_MakeVectors();
	vector src = Weapons_GetCameraPos();
	traceline(src, src + (v_forward * 256), FALSE, pl);
	lerp = Math_Lerp(18,6, trace_fraction);
	jitter[0] = (random(0,2) - 2) * (1 - trace_fraction);
	jitter[1] = (random(0,2) - 2) * (1 - trace_fraction);
	pos = (video_res / 2) + ([-lerp,-lerp] / 2);
	drawsubpic(
		pos + jitter,
		[lerp,lerp],
		"sprites/laserdot.spr_0.tga",
		[0,0],
		[1.0, 1.0],
		[1,1,1],
		1.0f,
		DRAWFLAG_ADDITIVE
	);

	/* menu */
	if (pl.a_ammo1 > 0) {
		vector col1, col2, col3, col4;
		string txt1, txt2, txt3, txt4;

		col1 = col2 = col3 = col4 = [1,1,1];
		switch (pl.a_ammo1) {
		case DMENU_LAUNCH:
			col1 = [0,1,0];
			break;
		case DMENU_FLIGHTPATH:
			col2 = [0,1,0];
			break;
		case DMENU_DETONATE:
			col3 = [0,1,0];
			break;
		case DMENU_PAYLOAD:
			col4 = [0,1,0];
			break;
		}

		txt1 = sprintf("LAUNCH: %s", lmodes[getstati(42)]);
		txt2 = sprintf("FLIGHTPATH: %s", fmodes[getstati(43)]);
		txt3 = sprintf("DETONATE: %s", dmodes[getstati(44)]);
		txt4 = sprintf("PAYLOAD: %s", pmodes[getstati(45)]);
		pos = video_mins + (video_res / 2) + [-80,-48];

		drawfont = FONT_20;
		drawstring(pos, txt1, [20,20], col1, 1.0f,
			DRAWFLAG_ADDITIVE);
		pos[1] += 24;
		drawstring(pos, txt2, [20,20], col2, 1.0f,
			DRAWFLAG_ADDITIVE);
		pos[1] += 24;
		drawstring(pos, txt3, [20,20], col3, 1.0f,
			DRAWFLAG_ADDITIVE);
		pos[1] += 24;
		drawstring(pos, txt4, [20,20], col4, 1.0f,
			DRAWFLAG_ADDITIVE);
		return;
	}

	pos = video_mins + (video_res / 2) + [-32,-15];
	drawsubpic(
		pos,
		[63,31],
		"sprites/crosshairs.spr_0.tga",
		[149/256,1/128],
		[63/256, 31/128],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);

	HUD_DrawAmmo2();
#endif
}

void
w_dml_hudpic(int selected, vector pos)
{
#ifdef CSQC
	drawpic(
		pos,
		"gfx/vgui/640_weapon_dml0.tga",
		[170,43],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_dml_precache(void)
{
	precache_model("models/v_dml.mdl");
	precache_model("sprites/laserdot.spr");
	precache_sound("weapons/dml_reload.wav");
	precache_sound("weapons/dml_customize.wav");
	precache_sound("weapons/dml_fire.wav");

#ifdef SSQC
	clientstat(42, EV_INTEGER, player::dml_launch);
	clientstat(43, EV_INTEGER, player::dml_flightpath);
	clientstat(44, EV_INTEGER, player::dml_detonate);
	clientstat(45, EV_INTEGER, player::dml_payload);
#endif
}

weapon_t w_dml =
{
	.id		= ITEM_DML,
	.slot		= 3,
	.slot_pos	= 1,
	.ki_spr		= "sprites/640hud1.spr_0.tga",
	.ki_size	= [48,16],
	.ki_xy		= [192,0],
	.draw		= w_dml_draw,
	.holster	= w_dml_holster,
	.primary	= w_dml_primary,
	.secondary	= w_dml_secondary,
	.reload		= __NULL__,
	.release	= w_dml_release,
	.crosshair	= w_dml_hud,
	.precache	= w_dml_precache,
	.pickup		= w_dml_pickup,
	.updateammo	= w_dml_updateammo,
	.wmodel		= w_dml_wmodel,
	.pmodel		= w_dml_pmodel,
	.deathmsg	= w_dml_deathmsg,
	.aimanim	= w_dml_aimanim,
	.hudpic		= w_dml_hudpic
};

/* entity definitions for pickups */
#ifdef SSQC
void
weapon_dml(void)
{
	Weapons_InitItem(WEAPON_DML);
}
#endif

#ifdef CSQC
int
w_dml_hudforward(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}

	switch (pl.a_ammo1) {
	case DMENU_LAUNCH:
		sendevent("w_dml_launch", "i", 1i);
		break;
	case DMENU_FLIGHTPATH:
		sendevent("w_dml_path", "i", 1i);
		break;
	case DMENU_DETONATE:
		sendevent("w_dml_det", "i", 1i);
		break;
	case DMENU_PAYLOAD:
		sendevent("w_dml_pay", "i", 1i);
		break;
	}
	return FALSE;
}
int
w_dml_hudback(player pl)
{
	if (pl.a_ammo1 <= 0) {
		return TRUE;
	}
	
	switch (pl.a_ammo1) {
	case DMENU_LAUNCH:
		sendevent("w_dml_launch", "i", -1i);
		break;
	case DMENU_FLIGHTPATH:
		sendevent("w_dml_path", "i", -1i);
		break;
	case DMENU_DETONATE:
		sendevent("w_dml_det", "i", -1i);
		break;
	case DMENU_PAYLOAD:
		sendevent("w_dml_pay", "i", -1i);
		break;
	}
	return FALSE;
}
#else
void
CSEv_w_dml_launch_i(int f)
{
	player pl = (player)self;
	pl.dml_launch = bound(0, pl.dml_launch + f, 1);
}

void
CSEv_w_dml_path_i(int f)
{
	player pl = (player)self;
	pl.dml_flightpath = bound(0, pl.dml_flightpath + f, 2);
}
void
CSEv_w_dml_det_i(int f)
{
	player pl = (player)self;
	pl.dml_detonate = bound(0, pl.dml_detonate + f, 3);
}

void
CSEv_w_dml_pay_i(int f)
{
	player pl = (player)self;
	pl.dml_payload = bound(0, pl.dml_payload + f, 1);
}
#endif
