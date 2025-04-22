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
	m_hintActivity = __NULL__;
	m_nodeFieldOfView = 360;
	m_hintGroup = __NULL__;
	m_ignoreFacing = IGNORE_DEFAULT;
	m_mindsetFilter = __NULL__;
};

void
ncHint::Save(float handle)
{
	ncIO::Save(handle);
	SaveString(handle, "hintType", m_hintType);
	SaveString(handle, "hintActivity", m_hintActivity);
	SaveFloat(handle, "nodeFieldOfView", m_nodeFieldOfView);
	SaveString(handle, "hintGroup", m_hintGroup);
	SaveFloat(handle, "ignoreFacing", m_ignoreFacing);
	SaveString(handle, "mindsetFilter", m_mindsetFilter);
}

void
ncHint::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "hintType":
		m_hintType = ReadString(strValue);
		break;
	case "hintActivity":
		m_hintActivity = ReadString(strValue);
		break;
	case "nodeFieldOfView":
		m_nodeFieldOfView = ReadFloat(strValue);
		break;
	case "hintGroup":
		m_hintGroup = ReadString(strValue);
		break;
	case "ignoreFacing":
		m_ignoreFacing = ReadFloat(strValue);
		break;
	case "mindsetFilter":
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
		m_hintActivity = ReadString(strValue);
		break;
	case "nodeFOV":
		m_nodeFieldOfView = ReadFloat(strValue);
		break;
	case "Group":
		m_hintGroup = ReadString(strValue);
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
}
