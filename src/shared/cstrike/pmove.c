
float GamePMove_Maxspeed(player target)
{
	float spd = serverkeyfloat("phy_maxspeed");

	switch (target.activeweapon)
	{
	case WEAPON_NONE:
		spd *= 1.0f;
		break;
	case WEAPON_M3:
		spd *= 0.92f;
		break;
	case WEAPON_XM1014:
		spd *= 0.96f;
		break;
	case WEAPON_MP5:
		spd *= 1.0f;
		break;
	case WEAPON_P90:
		spd *= 0.98f;
		break;
	case WEAPON_UMP45:
		spd *= 1.0f;
		break;
	case WEAPON_MAC10:
		spd *= 1.0f;
		break;
	case WEAPON_TMP:
		spd *= 1.0f;
		break;
	case WEAPON_AK47:
		spd *= 0.88f;
		break;
	case WEAPON_SG552:
		spd *= 0.94f;
		break;
	case WEAPON_M4A1:
		spd *= 0.92f;
		break;
	case WEAPON_AUG:
		spd *= 0.96f;
		break;
	case WEAPON_SCOUT:
		spd *= 1.04f;
		break;
	case WEAPON_AWP:
		spd *= 0.84f;
		break;
	case WEAPON_G3SG1:
		spd *= 0.84f;
		break;
	case WEAPON_SG550:
		spd *= 0.84f;
		break;
	case WEAPON_PARA:
		spd *= 0.88f;
		break;
	case WEAPON_USP45:
		spd *= 1.0f;
		break;
	case WEAPON_GLOCK18:
		spd *= 1.0f;
		break;
	case WEAPON_DEAGLE:
		spd *= 1.0f;
		break;
	case WEAPON_P228:
		spd *= 1.0f;
		break;
	case WEAPON_ELITES:
		spd *= 1.0f;
		break;
	case WEAPON_FIVESEVEN:
		spd *= 1.0f;
		break;
	case WEAPON_KNIFE:
		spd *= 1.0f;
		break;
	case WEAPON_HEGRENADE:
		spd *= 1.0f;
		break;
	case WEAPON_FLASHBANG:
		spd *= 1.0f;
		break;
	case WEAPON_SMOKEGRENADE:
		spd *= 1.0f;
		break;
	case WEAPON_C4BOMB:
		spd *= 1.0f;
		break;
	}

	if (target.flags & FL_CROUCHING)
		spd *= 0.5f;

	return spd;
}
