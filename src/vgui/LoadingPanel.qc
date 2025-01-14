/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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

class
vguiLoadingPanel:vguiWindow
{
	void vguiLoadingPanel(void);
	virtual void Spawned(void);
	nonvirtual void UpdateProgress(void);

private:

	vguiLabel m_lblLoading;
	vguiButton m_btnCancel;
	vguiProgressBar m_progressBar;
	float timePassed;
};

void
vguiLoadingPanel::vguiLoadingPanel(void)
{
	m_lblLoading = __NULL__;
	m_btnCancel = __NULL__;
}

void
vguiLoadingPanel::UpdateProgress(void)
{
	timePassed += frametime;

	if (timePassed > 1.0f)
		timePassed = 0.0f;

	m_progressBar.SetProgress(timePassed);
}

void
vguiLoadingPanel::Spawned(void)
{
	super::Spawned();

	SetSize( [380,112] );
	SetTitle( "Loading..." );
	SetStyleMask(vguiWindowTitled);

	m_progressBar = spawn( vguiProgressBar );
	m_progressBar.SetSize( [260,24] );
	m_progressBar.SetPos( [20,64] );

	m_btnCancel = spawn( vguiButton );
	m_btnCancel.SetTitle( "Cancel" );
	m_btnCancel.SetSize( [72,24] );
	m_btnCancel.SetPos( [288,64] );

	m_lblLoading = spawn( vguiLabel );
	m_lblLoading.SetTitle( "Starting local game server" );
	m_lblLoading.SetSize( [248,16] );
	m_lblLoading.SetPos( [20,40] );
	//m_lblLoading.SetAlignment(AF_NONE);

	//m_btnCancel.SetFunc( QuitGame_No );

	Add( m_progressBar );
	Add( m_btnCancel );
	Add( m_lblLoading );
	SetPos( ( g_vidsize / 2 ) - ( GetSize() / 2 ) );
}
