#ifdef SERVER
class base_player:CBaseEntity
#else
class base_player
#endif
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
	 * effects of some bits. Such as invisibility, quad, etc. 
	 * also, modders probably want 32 bits for items. */
	int g_items; 

	float activeweapon;
	float viewzoom;
	vector punchangle;
	vector view_ofs;
	float weapontime;

	/* any mods that use hooks */
	entity hook;

#ifdef CLIENT
	/* Prediction */
	vector net_origin;
	vector net_velocity;
	float net_flags;
	float net_w_attack_next;
	float net_w_idle_next;
	float net_jumptime;
	float net_teleport_time;
	float net_weapontime;
	float net_viewzoom;
	vector net_punchangle;
	int net_ammo1;
	int net_ammo2;
	int net_ammo3;
	int sequence;
#else

	/* conditional networking */
	int old_modelindex;
	vector old_origin;
	vector old_angles;
	vector old_velocity;
	int old_flags;
	int old_activeweapon;
	int old_items;
	float old_health;
	float old_armor;
	int old_movetype;
	float old_viewofs;
	int old_baseframe;
	int old_frame;
	int old_a_ammo1;
	int old_a_ammo2;
	int old_a_ammo3;
	
	int voted;
#endif
}; 
