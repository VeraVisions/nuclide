void
Shake_Update(player pl)
{
	if (pSeat->m_flShakeDuration > 0.0) {
		vector vecShake = [0,0,0];
		vecShake[0] += random() * 3;
		vecShake[1] += random() * 3;
		vecShake[2] += random() * 3;
		pl.punchangle += (vecShake * pSeat->m_flShakeAmp) * (pSeat->m_flShakeDuration / pSeat->m_flShakeTime);
		pSeat->m_flShakeDuration -= clframetime;
	}
}
