
class player
{
	entity p_model;
	int p_hand_bone;
	int p_model_bone;

	vector netorigin;
	vector netvelocity;
	float netflags;
	
	float activeweapon;
	float weapons;
	float lastweapon;

	float health;
	float armor;
	float pitch;
	float viewzoom;
	
	vector view_ofs;

#ifdef CSQC
	virtual void() gun_offset;
	virtual void() draw;
	virtual float() predraw;
#endif
};
