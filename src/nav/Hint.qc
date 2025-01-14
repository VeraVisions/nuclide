/*
 * Copyright (c) 2016-2025 Vera Visions LLC.
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

void
ncHint::ncHint(void)
{
	m_hintType = __NULL__;
	m_strHintActivity = __NULL__;
	m_flNodeFOV = 360;
	m_strHintGroup = __NULL__;
	m_ignoreFacing = IGNORE_DEFAULT;
	m_mindsetFilter = __NULL__;
};

void
ncHint::Save(float handle)
{
	super::Save(handle);
	SaveString(handle, "m_hintType", m_hintType);
	SaveString(handle, "m_strHintActivity", m_strHintActivity);
	SaveFloat(handle, "m_flNodeFOV", m_flNodeFOV);
	SaveString(handle, "m_strHintGroup", m_strHintGroup);
	SaveFloat(handle, "m_ignoreFacing", m_ignoreFacing);
	SaveString(handle, "m_mindsetFilter", m_mindsetFilter);
}

void
ncHint::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "m_hintType":
		m_hintType = ReadString(strValue);
		break;
	case "m_strHintActivity":
		m_strHintActivity = ReadString(strValue);
		break;
	case "m_flNodeFOV":
		m_flNodeFOV = ReadFloat(strValue);
		break;
	case "m_strHintGroup":
		m_strHintGroup = ReadString(strValue);
		break;
	case "m_ignoreFacing":
		m_ignoreFacing = ReadFloat(strValue);
		break;
	case "m_mindsetFilter":
		m_mindsetFilter = ReadString(strValue);
		break;
	default:
		super::Restore(strKey, strValue);
	}
}

void
ncHint::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "hinttype":
		m_hintType = ReadString(strValue);
		break;
	case "hintactivity":
		m_strHintActivity = ReadString(strValue);
		break;
	case "nodeFOV":
		m_flNodeFOV = ReadFloat(strValue);
		break;
	case "StartDisabled":
		m_bStartDisabled = ReadFloat(strValue) == 1 ? true : false;
		break;
	case "Group":
		m_strHintGroup = ReadString(strValue);
		break;
	case "IgnoreFacing":
		m_ignoreFacing = ReadFloat(strValue);
		break;
	case "MinimumState":
		m_mindsetFilter = ReadString(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
ncHint::Spawned(void)
{
	super::Spawned();
	SetEditorIcon("help");
}
