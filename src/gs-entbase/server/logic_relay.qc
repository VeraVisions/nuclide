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

enumflags
{
	LOGICRELAY_ONCE,
	LOGICRELAY_FAST
};

class
logic_relay:NSPointTrigger
{
public:
	void logic_relay(void);

	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
	virtual void Input(entity, string, string);
	virtual void Save(float);
	virtual void Restore(string, string);

private:
	bool m_bStartDisabled;
	bool m_bEnabled;
};

void
logic_relay::logic_relay(void)
{
	m_bStartDisabled = false;
}

void
logic_relay::Respawn(void)
{
	InitPointTrigger();
	m_bEnabled = m_bStartDisabled;
}

void
logic_relay::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "StartDisabled":
		m_bStartDisabled = ReadBool(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
logic_relay::Save(float handle)
{
	super::Save(handle);

	SaveBool(handle, "m_bStartDisabled", m_bStartDisabled);
	SaveBool(handle, "m_bEnabled", m_bEnabled);
}

void
logic_relay::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_bStartDisabled":
		m_bStartDisabled = ReadBool(strValue);
		break;
	case "m_bEnabled":
		m_bEnabled = ReadBool(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
logic_relay::Input(entity activatorEntity, string inputName, string dataField)
{
	switch (inputName) {
	case "Enable":
		m_bEnabled = true;
		break;
	case "Disable":
		m_bEnabled = false;
		break;
	case "Trigger":
		if (m_bEnabled == true) {
			/* if we don't allow fast retrigger... */
			if (HasSpawnFlags(LOGICRELAY_FAST) == false) {
				if (CheckOutput(m_strOnTrigger) == false) {
					return;
				}
			}

			UseOutput(activatorEntity, m_strOnTrigger);

			/* remove forever! */
			if (HasSpawnFlags(LOGICRELAY_ONCE)) {
				Destroy();
			}
		}
		break;
	case "Toggle":
		m_bEnabled = (m_bEnabled) ? false : true;
		break;
	/* TODO: complete this mess */
	case "CancelPending":
		break;
	case "EnableRefire":
		break;
	default:
		super::Input(activatorEntity, inputName, dataField);
	}
}