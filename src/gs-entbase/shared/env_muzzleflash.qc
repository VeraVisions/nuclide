/*
 * Copyright (c) 2023 Vera Visions LLC.
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

/*! \brief Shared-Entity: Muzzleflash Emitter */
/*!QUAKED env_muzzleflash (1 .5 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
Creates a muzzleflash effect when triggered.

# KEYS
- "targetname" : Name
- "parentname" : Entity it's attached to.
- "parentattachment" : Name of the attachment to parent to.
- "scale" : Scale multiplier of the muzzleflash.

# INPUTS
- "Fire" : Triggers the effect.

# TRIVIA
This entity was introduced in Half-Life 2 (2004).

@ingroup sharedentity
@ingroup pointentity
*/
class
env_muzzleflash:ncEntity
{
public:
	void env_muzzleflash(void);

#ifdef SERVER
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void SpawnKey(string, string);
	virtual void Input(entity, string, string);
	virtual void Trigger(entity, triggermode_t);
#endif

#ifdef CLIENT
	virtual float predraw(void);
#endif

private:
	string m_strAttachmentName;
	int m_iAttachment;
	ncRenderableEntity m_eOwner;
	string m_strModel;
	string m_strParticle;
	entity m_eMuzzler; /* lol */
	bool m_forceAdditive;
};

void
env_muzzleflash::env_muzzleflash(void)
{
	m_iAttachment = 0i;
	m_eOwner = __NULL__;
	m_strModel = __NULL__;
	m_strParticle = __NULL__;
	m_eMuzzler = __NULL__;
	scale = 1.0f;
	m_forceAdditive = false;
}

#ifdef SERVER
void
env_muzzleflash::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_strAttachmentName", m_strAttachmentName);
	SaveInt(handle, "m_iAttachment", m_iAttachment);
	SaveEntity(handle, "m_eOwner", m_eOwner);
	SaveString(handle, "m_strModel", m_strModel);
	SaveString(handle, "m_strParticle", m_strParticle);
	SaveEntity(handle, "m_eMuzzler", m_eMuzzler);
	SaveBool(handle, "m_forceAdditive", m_forceAdditive);
}

void
env_muzzleflash::Restore(string strKey, string setValue)
{
	switch (strKey) {
	case "m_strAttachmentName":
		m_strAttachmentName = ReadString(setValue);
		break;
	case "m_iAttachment":
		m_iAttachment = ReadInt(setValue);
		break;
	case "m_eOwner":
		m_eOwner = (ncRenderableEntity)ReadEntity(setValue);
		break;
	case "m_strModel":
		m_strModel = ReadString(setValue);
		break;
	case "m_strParticle":
		m_strParticle = ReadString(setValue);
		break;
	case "m_eMuzzler":
		m_eMuzzler = ReadEntity(setValue);
		break;
	case "m_forceAdditive":
		m_forceAdditive = ReadBool(setValue);
		break;
	default:
		super::Restore(strKey, setValue);
	}
}

void
env_muzzleflash::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "parentname":
		m_parent = ReadString(setValue);
		break;
	case "parentattachment":
		m_strAttachmentName = ReadString(setValue);
		break;
	case "attachment":
		m_iAttachment = ReadInt(setValue);
		break;
	case "scale":
		scale = ReadFloat(setValue);
		break;
	case "model":
		model = ReadString(setValue);
		break;
	case "additive":
		m_forceAdditive = ReadBool(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
		break;
	}
}

void
env_muzzleflash::Input(entity eAct, string strKey, string setValue)
{
	switch (strKey) {
	case "Fire":
		Trigger(eAct, TRIG_TOGGLE);
		break;
	default:
		super::Input(eAct, strKey, setValue);
	}
}

void
env_muzzleflash::Trigger(entity theActivator, triggermode_t triggerState)
{
	ncEntity targetEnt = __NULL__;
	vector targetPosition = GetOrigin();

	if (STRING_SET(m_parent)) {
		targetEnt = (ncEntity)find(world, ::targetname, m_parent);

		if (!targetEnt) {
			EntWarning("Entity specified but not found.");
			return;
		}
	}

	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_MUZZLEFLASH);
	WriteEntity(MSG_MULTICAST, targetEnt);
	WriteByte(MSG_MULTICAST, m_iAttachment);
	WriteFloat(MSG_MULTICAST, scale);
	WriteShort(MSG_MULTICAST, getmodelindex(model));

	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}
#endif

#ifdef CLIENT
var bool autocvar_cg_muzzleDLight = true;
var vector autocvar_cg_muzzleDLightColor = [1,0.45,0];
float
env_muzzleflash::predraw(void)
{
	vector muzzlePos;

	if (m_iAttachment) {
		muzzlePos = gettaginfo(m_eOwner, (float)m_iAttachment);
	} else {
		muzzlePos = origin;
	}

	if (autocvar_cg_muzzleDLight == true) {
		float p = dynamiclight_add(muzzlePos, 150, autocvar_cg_muzzleDLightColor);
		dynamiclight_set(p, LFIELD_STYLE, 64);
	}

	setorigin(this, muzzlePos);

	if (m_forceAdditive) {
	 	effects = EF_ADDITIVE;
	}

	angles = m_eOwner.angles;
	addentity(this);
	alpha -= frametime * 16.0f;

	if (m_eOwner.alpha == 0.0f) {
		alpha = 0.0f;
	}

	if (alpha <= 0.0) {
		Destroy();
	}

	return (PREDRAW_NEXT);
}

/* basically re-implementing TE_BEAMCYLINDER*/
void
EV_MuzzleFlash_Parse(void)
{
	env_muzzleflash tempMuzzle = spawn(env_muzzleflash);

	tempMuzzle.m_eOwner = (ncRenderableEntity)findfloat(world, entnum, readentitynum());
	tempMuzzle.m_iAttachment = readbyte();
	tempMuzzle.scale = readfloat();
	tempMuzzle.modelindex = readshort();
	tempMuzzle.alpha = 1.0f;

	setorigin(tempMuzzle, tempMuzzle.m_eOwner.origin);
	setsize(tempMuzzle, [0,0,0], [0,0,0]);
	tempMuzzle.drawmask = MASK_GLOWS;
}

void
EV_MuzzleFlash_Create(entity muzzleOwner, int attachmentID, float muzzleScale, int muzzleModel)
{
	env_muzzleflash tempMuzzle = spawn(env_muzzleflash);

	tempMuzzle.m_eOwner = (ncRenderableEntity)muzzleOwner;
	tempMuzzle.m_iAttachment = attachmentID;
	tempMuzzle.scale = muzzleScale;
	tempMuzzle.alpha = 1.0f;
	tempMuzzle.modelindex = muzzleModel;
	setmodel(tempMuzzle, modelnameforindex(muzzleModel));

	setorigin(tempMuzzle, tempMuzzle.m_eOwner.origin);
	setsize(tempMuzzle, [0,0,0], [0,0,0]);
	tempMuzzle.drawmask = MASK_GLOWS;
}

void
EV_MuzzleFlash_CreateAdditive(entity muzzleOwner, int attachmentID, float muzzleScale, int muzzleModel)
{
	env_muzzleflash tempMuzzle = spawn(env_muzzleflash);

	tempMuzzle.m_eOwner = (ncRenderableEntity)muzzleOwner;
	tempMuzzle.m_iAttachment = attachmentID;
	tempMuzzle.scale = muzzleScale;
	tempMuzzle.alpha = 1.0f;
	tempMuzzle.modelindex = muzzleModel;
	tempMuzzle.m_forceAdditive = true;
	setmodel(tempMuzzle, modelnameforindex(muzzleModel));

	setorigin(tempMuzzle, tempMuzzle.m_eOwner.origin);
	setsize(tempMuzzle, [0,0,0], [0,0,0]);
	tempMuzzle.drawmask = MASK_GLOWS;
}

void
EV_MuzzleFlash_CreateAtPos(entity muzzleOwner, vector pos, float muzzleScale, int muzzleModel)
{
	env_muzzleflash tempMuzzle = spawn(env_muzzleflash);

	tempMuzzle.m_eOwner = (ncRenderableEntity)muzzleOwner;
	tempMuzzle.scale = muzzleScale;
	tempMuzzle.alpha = 1.0f;
	tempMuzzle.modelindex = muzzleModel;
	setmodel(tempMuzzle, modelnameforindex(muzzleModel));

	setorigin(tempMuzzle, pos);
	setsize(tempMuzzle, [0,0,0], [0,0,0]);
	tempMuzzle.drawmask = MASK_GLOWS;
}
#endif
