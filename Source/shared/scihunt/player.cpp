
class player
{
	float health;
	float armor;

	/* When the weapon is done firing */
	float w_attack_next;
	/* When to play the next idle animation */ 
	float w_idle_next;

	/* Magazine/Clip */
	int a_ammo1;
	/* Rest in the inventory */
	int a_ammo2;
	/* Special ammo */
	int a_ammo3;

	/* We can't use the default .items field, because FTE will assume
	 * effects of some bits. Such as invisibility, quad, etc. */
	int g_items; 

	float activeweapon;
	float viewzoom;
	vector view_ofs;

	/* Weapon specific */
	int glock_mag;
	int mp5_mag;
	int python_mag;
	int shotgun_mag;
	int crossbow_mag;
	int rpg_mag;
	int satchel_chg;
	int cannon_mag;

#ifdef CSQC
	/* External model */
	entity p_model;
	int playertype;
	int p_hand_bone;
	int p_model_bone;
	float pitch;
	float lastweapon;

	/* Prediction */
	vector netorigin;
	vector netvelocity;
	float netflags;
	float net_w_attack_next;
	float net_w_idle_next;
	float netjumptime;
	float netteleport_time;

	virtual void() set_model;
	virtual void() gun_offset;
	virtual void() draw;
	virtual float() predraw;
	virtual void() postdraw;
#else
	int ammo_9mm;
	int ammo_357;
	int ammo_buckshot;
	int ammo_m203_grenade;
	int ammo_bolt;
	int ammo_rocket;
	int ammo_uranium;
	int ammo_handgrenade;
	int ammo_satchel;
	int ammo_tripmine;
	int ammo_snark;
	int ammo_hornet;
#endif
};
