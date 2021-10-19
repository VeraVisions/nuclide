/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
NSOutput::TriggerOutput(void)
{
	/* plug into all the inputs. */
	for (entity f = world; (f = find(f, ::targetname, m_strTarget));) {
		NSEntity trigger = (NSEntity)f;

		if (trigger.Input != __NULL__) {
			trigger.Input(m_eActivator, m_strInput, m_strData);
		}
	}

	/* we're not -1 (infinite) and we've still got one use to deduct */
	if (m_iCount > 0)
		m_iCount--;
}

void
NSOutput::Init(void)
{
	/* Init of NSIO will tokenize __fullspawndata which
	   in turn will break NSIO::CreateOutput's tokenize loop,
	   as we'll be creating a bunch of NSOutputs in there */
}

void
NSOutput::Respawn(void)
{
	/* gotta reset our counter */
	m_iCount = m_iOldCount;
}

void
NSOutput::NSOutput(void)
{
	/* Make sure Respawn() will be called between rounds */
	identity = 1;
}
