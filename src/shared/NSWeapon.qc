void
NSWeapon::NSWeapon(void)
{

}

/* calls */
void
NSWeapon::Precache(void)
{
}

void
NSWeapon::Draw(void)
{
}

void
NSWeapon::Holster(void)
{
}

void
NSWeapon::Primary(void)
{
}

void
NSWeapon::Secondary(void)
{
}

void
NSWeapon::Reload(void)
{
}

void
NSWeapon::Release(void)
{
}

void
NSWeapon::ClientPredraw(void)
{
}

void
NSWeapon::ClientPostdraw(void)
{
}

/* get */
string
NSWeapon::GetPlayerModel(void)
{
	return "models/error.vvm";
}

string
NSWeapon::GetWorldModel(void)
{
	return "models/error.vvm";
}

string
NSWeapon::GetPrintName(void)
{
	return m_strName;
}

int
NSWeapon::GetSlot(void)
{
	return m_iSlot;
}

int
NSWeapon::GetSlotPos(void)
{
	return m_iSlotPos;
}

bool
NSWeapon::AllowDropping(void)
{
	return false;
}

int
NSWeapon::GetWeight(void)
{
	return 0;
}

int
NSWeapon::GetPlayerAnim(void)
{
	return 0;
}

bool
NSWeapon::IsEmpty(void)
{
	return false;
}

string
NSWeapon::GetObituaryMessage(void)
{
	return "%s killed %s with Unknown";
}

int
NSWeapon::GetType(void)
{
	return 0;
}

int
NSWeapon::GetClip1(void)
{
	return 0;
}

int
NSWeapon::GetClip2(void)
{
	return 0;
}

int
NSWeapon::GetMaxClip1(void)
{
	return 0;
}

int
NSWeapon::GetMaxClip2(void)
{
	return 0;
}

float
NSWeapon::GetNextPrimaryFire(void)
{
	return m_flPrimaryNext;
}

float
NSWeapon::GetNextSecondaryFire(void)
{
	return m_flSecondaryNext;
}

float
NSWeapon::LastFireTime(void)
{
	return m_flLastFired;
}

void
NSWeapon::SetClip1(int new_clip)
{
	m_iClip1 = new_clip;
}

void
NSWeapon::SetClip2(int new_clip)
{
	m_iClip1 = new_clip;
}

bool
NSWeapon::AllowsAutoSwitchFrom(void)
{
	return true;
}

bool
NSWeapon::AllowsAutoSwitchTo(void)
{
	return true;
}

bool
NSWeapon::HasAmmo(void)
{
	return false;
}
