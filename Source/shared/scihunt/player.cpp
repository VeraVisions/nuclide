
class player
{
	float health;
	float armor;

	float w_attack_next; /* When the weapon is done firing */
	float w_idle_next; /* When to play the next idle animation */

	int a_ammo1; // Magazine/Clip
	int a_ammo2; // Rest in the inventory
	int a_ammo3; // Special ammo

	float items;
	float activeweapon;
	float viewzoom;
	vector view_ofs;

	/* Weapon specific */
        int cannon_mag;
	int glock_mag;

#ifdef CSQC
	/* External model */
	entity p_model;
	int p_hand_bone;
	int p_model_bone;
	float pitch;
	float lastweapon;
	
	/* Prediction */
	vector netorigin;
	vector netvelocity;
	float netflags;
	float net_w_attack_next; /* When the weapon is done firing */
	float net_w_idle_next; /* When to play the next idle animation */

	virtual void() gun_offset;
	virtual void() draw;
	virtual float() predraw;
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
