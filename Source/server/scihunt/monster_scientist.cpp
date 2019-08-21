/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

var int autocvar_sh_scialert = FALSE;
var int autocvar_sh_scispeed = 40;

enum {
	SCI_IDLE,
	SCI_WALK,
	SCI_RUN,
	SCI_DEAD
};

enum {
	SCIA_WALK,
	SCIA_WALKSCARED,
	SCIA_RUN,
	SCIA_RUNSCARED,
	SCIA_RUNLOOK,
	SCIA_180LEFT,
	SCIA_180RIGHT,
	SCIA_FLINCH,
	SCIA_PAIN,
	SCIA_PAINLEFT,
	SCIA_PAINRIGHT,
	SCIA_PAINLEGLEFT,
	SCIA_PAINLEGRIGHT,
	SCIA_IDLE1,
	SCIA_IDLE2,
	SCIA_IDLE3,
	SCIA_IDLE4,
	SCIA_IDLE5,
	SCIA_IDLE6,
	SCIA_SCARED_END,
	SCIA_SCARED1,
	SCIA_SCARED2,
	SCIA_SCARED3,
	SCIA_SCARED4,
	SCIA_PANIC,
	SCIA_FEAR1,
	SCIA_FEAR2,
	SCIA_CRY,
	SCIA_SCI1,
	SCIA_SCI2,
	SCIA_SCI3,
	SCIA_DIE_SIMPLE,
	SCIA_DIE_FORWARD1,
	SCIA_DIE_FORWARD2,
	SCIA_DIE_BACKWARD,
	SCIA_DIE_HEADSHOT,
	SCIA_DIE_GUTSHOT,
	SCIA_LYING1,
	SCIA_LYING2,
	SCIA_DEADSIT,
	SCIA_DEADTABLE1,
	SCIA_DEADTABLE2,
	SCIA_DEADTABLE3
};

enumflags
{
	SCIF_USED,
	SCIF_SCARED,
	SCIF_FEAR,
	SCIF_SEEN,
	SCIF_FALLING
};

string sci_snddie[] = {
	"scientist/sci_die1.wav",
	"scientist/sci_die2.wav",
	"scientist/sci_die3.wav",
	"scientist/sci_die4.wav"
};

string sci_sndchitchat[] = {
	"scientist/absolutely.wav",
	"scientist/absolutelynot.wav",
	"scientist/administrator.wav",
	"scientist/alienappeal.wav",
	"scientist/alientrick.wav",
	"scientist/allnominal.wav",
	"scientist/areyouthink.wav",
	"scientist/asexpected.wav",
	"scientist/beverage.wav",
	"scientist/bloodsample.wav",
	"scientist/cantbeserious.wav",
	"scientist/chaostheory.wav",
	"scientist/completelywrong.wav",
	"scientist/containfail.wav",
	"scientist/correcttheory.wav",
	"scientist/dine.wav",
	"scientist/dontknow.wav",
	"scientist/donuteater.wav",
	"scientist/doyousmell.wav",
	"scientist/evergetout.wav",
	"scientist/everseen.wav",
	"scientist/fascinating.wav",
	"scientist/goodpaper.wav",
	"scientist/headcrab.wav",
	"scientist/hideglasses.wav",
	"scientist/hopenominal.wav",
	"scientist/howinteresting.wav",
	"scientist/hungryyet.wav",
	"scientist/ibelieveso.wav",
	"scientist/idontthinkso.wav",
	"scientist/importantspecies.wav",
	"scientist/improbable.wav",
	"scientist/imsure.wav",
	"scientist/inconclusive.wav",
	"scientist/ipredictedthis.wav",
	"scientist/justasked.wav",
	"scientist/lambdalab.wav",
	"scientist/limitsok.wav",
	"scientist/lowervoice.wav",
	"scientist/luckwillchange.wav",
	"scientist/needsleep.wav",
	"scientist/neverseen.wav",
	"scientist/nodoubt.wav",
	"scientist/nogrant.wav",
	"scientist/noguess.wav",
	"scientist/noidea.wav",
	"scientist/noo.wav",
	"scientist/notcertain.wav",
	"scientist/nothostile.wav",
	"scientist/notsure.wav",
	"scientist/ofcourse.wav",
	"scientist/ofcoursenot.wav",
	"scientist/organicmatter.wav",
	"scientist/perculiarmarks.wav",
	"scientist/perculiarodor.wav",
	"scientist/perhaps.wav",
	"scientist/positively.wav",
	"scientist/repeat.wav",
	"scientist/reportflux.wav",
	"scientist/rescueus.wav",
	"scientist/ridiculous.wav",
	"scientist/right.wav",
	"scientist/rightway.wav",
	"scientist/rumorclean.wav",
	"scientist/runtest.wav",
	"scientist/seencup.wav",
	"scientist/shakeunification.wav",
	"scientist/shutdownchart.wav",
	"scientist/shutup.wav",
	"scientist/simulation.wav",
	"scientist/smellburning.wav",
	"scientist/softethics.wav",
	"scientist/stimulating.wav",
	"scientist/stopasking.wav",
	"scientist/thatsodd.wav",
	"scientist/theoretically.wav",
	"scientist/uselessphd.wav",
	"scientist/waithere.wav",
	"scientist/whatnext.wav",
	"scientist/whocansay.wav",
	"scientist/whoresponsible.wav",
	"scientist/whyaskme.wav",
	"scientist/yees.wav"
};

string sci_sndhear[] = {
	"scientist/hearsomething.wav",
	"scientist/startle1.wav",
	"scientist/startle2.wav",
	"scientist/startle3.wav",
	"scientist/startle4.wav",
	"scientist/startle5.wav",
	"scientist/startle6.wav",
	"scientist/startle7.wav",
	"scientist/startle8.wav",
	"scientist/startle9.wav",
	"scientist/whatissound.wav"
};

string sci_sndpain[] = {
	"scientist/sci_pain1.wav",
	"scientist/sci_pain2.wav",
	"scientist/sci_pain3.wav",
	"scientist/sci_pain4.wav",
	"scientist/sci_pain5.wav",
	"scientist/sci_pain6.wav",
	"scientist/sci_pain7.wav",
	"scientist/sci_pain8.wav",
	"scientist/sci_pain9.wav",
	"scientist/sci_pain10.wav"
};

string sci_sndsee[] = {
	"scientist/afellowsci.wav",
	"scientist/ahfreeman.wav",
	"scientist/freeman.wav",
	"scientist/freemanalive.wav",
	"scientist/goodtoseeyou.wav",
	"scientist/greetings.wav",
	"scientist/greetings2.wav",
	"scientist/hello.wav",
	"scientist/hellofreeman.wav",
	"scientist/hellofromlab.wav",
	"scientist/hellothere.wav",
	"scientist/inmesstoo.wav",
	"scientist/newhevsuit.wav"
};

string sci_sndscream[] = {
	"scientist/scream1.wav",
	"scientist/scream2.wav",
	"scientist/scream3.wav",
	"scientist/scream4.wav",
	"scientist/dontwantdie.wav",
	"scientist/scream5.wav",
	"scientist/scream6.wav",
	"scientist/scream7.wav",
	"scientist/evergetout.wav",
	"scientist/scream8.wav",
	"scientist/scream9.wav",
	"scientist/scream10.wav",
	"scientist/scream11.wav",
	"scientist/getoutalive.wav",
	"scientist/scream12.wav",
	"scientist/scream13.wav",
	"scientist/scream14.wav",
	"scientist/scream15.wav",
	"scientist/scream16.wav",
	"scientist/getoutofhere.wav",
	"scientist/scream17.wav",
	"scientist/scream18.wav",
	"scientist/scream19.wav",
	"scientist/gottogetout.wav",
	"scientist/scream20.wav",
	"scientist/scream21.wav",
	"scientist/scream22.wav",
	"scientist/youinsane.wav",
	"scientist/scream23.wav",
	"scientist/scream24.wav",
	"scientist/scream25.wav"
};

string sci_sndstop[] = {
	"scientist/stop1.wav",
	"scientist/stop2.wav",
	"scientist/stop3.wav",
	"scientist/stop4.wav",
	"scientist/sorryimleaving.wav"
};

string sci_snduse[] = {
	"scientist/alright.wav",
	"scientist/excellentteam.wav",
	"scientist/fellowscientist.wav",
	"scientist/fine.wav",
	"scientist/hopeyouknow.wav",
	"scientist/leadtheway.wav",
	"scientist/letsgo.wav",
	"scientist/yes3.wav",
	"scientist/yesletsgo.wav"
};

string sci_snduseno[] = {
	"scientist/beenaburden.wav",
	"scientist/illwait.wav",
	"scientist/illwaithere.wav",
	"scientist/istay.wav",
	"scientist/reconsider.wav",
	"scientist/slowingyou.wav",
	"scientist/whyleavehere.wav"
};


class monster_scientist:CBaseEntity
{
	vector m_vecLastUserPos;
	entity m_eUser;
	entity m_eRescuer;

	float m_flScreamTime;
	float m_flPainTime;
	float m_flChangePath;
	float m_flTraceTime;
	float m_flPitch;
	int m_iFlags;
	void() monster_scientist;

	virtual void() touch;
	virtual void() Hide;
	virtual void() Respawn;
	virtual void() PlayerUse;
	virtual void(int) vPain;
	virtual void(int) vDeath;
	virtual void() Physics;
	virtual void() Scream;
	virtual void() Gib;
	virtual void() WarnOthers;
	virtual void(string) Speak;
};

void monster_scientist::Speak(string msg)
{
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_SPEAK);
	WriteEntity(MSG_MULTICAST, this);
	WriteString(MSG_MULTICAST, msg);
	WriteFloat(MSG_MULTICAST, m_flPitch);
	msg_entity = this;
	multicast(origin, MULTICAST_PVS);
}

void monster_scientist::Gib(void)
{
	takedamage = DAMAGE_NO;
	Effect_GibHuman(this.origin);
	Hide();
}

void monster_scientist::WarnOthers(void)
{
	for (entity b = world; (b = find(b, ::classname, "monster_scientist"));) {
		if (vlen(b.origin - origin) < 512) {
			monster_scientist sci = (monster_scientist)b;
			sci.m_iFlags |= SCIF_FEAR | SCIF_SEEN;
			sci.m_eUser = world;
			sci.m_eRescuer = world;
		}
	}
}

void monster_scientist::Scream(void)
{
	if (m_flScreamTime > time) {
		return;
	}

	int rand = floor(random(0,sci_sndscream.length));
	Speak(sci_sndscream[rand]);
	m_flScreamTime = time + 5.0f;
}

void monster_scientist::Physics(void)
{
	float spvel;
	input_movevalues = [0,0,0];
	input_impulse = 0;
	input_buttons = 0;

	if (!(m_iFlags & SCIF_SEEN)) {
		for (entity b = world; (b = find(b, ::classname, "player"));) {
			/* Find players in a 256 unit radius */
			if (vlen(b.origin - origin) < 256) {
				/* If we can't physically see him, don't say hi. */
				traceline(origin, b.origin, FALSE, this);
				if (trace_ent != b) {
					continue;
				}

				if (random() < 0.5) {
					int rand = floor(random(0,sci_sndsee.length));
					Speak(sci_sndsee[rand]);
				}

				m_iFlags |= SCIF_SEEN;
				break;
			}
		}
	}
	
	/* Deal with a hostage being rescued when it's following someone else */
	if (m_eRescuer.classname == "monster_scientist") {
		if (m_eRescuer.solid == SOLID_NOT) {
			m_eRescuer = m_eUser;
		}
	}
	/* Deal with the hostage losing its rescuer (death) */
	if (m_eUser.health <= 0) {
		m_eUser = world;
	}

	if (m_eUser!= world) {
		v_angle = vectoangles(m_eRescuer.origin - origin);
		v_angle[0] = 0;
		v_angle[1] = Math_FixDelta(v_angle[1]);
		v_angle[2] = 0;

		/* Give up after 1024 units */
		if (vlen(m_eRescuer.origin - origin) > 1024) {
			m_eUser = world;
		} else if (vlen(m_eRescuer.origin - origin) > 64) {
			input_movevalues[0] = 240;

			other = world;
			traceline(origin, /*mins, maxs, */m_eRescuer.origin, MOVE_OTHERONLY, this);

			/* Tracing failed, there's world geometry in the way */
			if (trace_fraction < 1.0f) {
				v_angle = vectoangles(m_vecLastUserPos - origin);
				v_angle[0] = 0;
				v_angle[1] = Math_FixDelta(v_angle[1]);
				v_angle[2] = 0;
			} else {
				m_vecLastUserPos = m_eRescuer.origin;
			}

			/* Trace again to see if another hostage is in our path and if so
			 * follow them instead, this makes pathing easier */
			traceline(origin, /*mins, maxs,*/ m_vecLastUserPos, FALSE, this);
			if (trace_ent.classname == "monster_scientist") {
				monster_scientist que = (monster_scientist)trace_ent;
				if (que.m_eRescuer == m_eUser) {
					if (trace_ent != this) {
						m_eRescuer = trace_ent;
					}
				}
			}
		}
	} else if (m_iFlags & SCIF_FEAR) {
		Scream();
		maxspeed = 240 * (autocvar_sh_scispeed/40);
		input_movevalues = [maxspeed, 0, 0];

		if (m_flTraceTime < time) {
			traceline(self.origin, self.origin + (v_forward * 32), FALSE, this);
			
			if (trace_fraction < 1.0f) {
				m_flChangePath = 0.0f;
			}
			m_flTraceTime = time + 0.5f;
		}

		if (m_flChangePath < time) {
			v_angle[1] -= 180 + (random(-25, 25));
			v_angle[1] = Math_FixDelta(v_angle[1]);
			m_flChangePath = time + floor(random(2,10));
		}
	}

	input_angles = angles = v_angle;
	input_timelength = frametime;
	
	if (m_flPainTime > time) {
		input_movevalues = [0,0,0];
	} else {
		spvel = vlen(velocity);

		if (spvel < 5) {
			frame = (m_iFlags & SCIF_SCARED) ? SCIA_SCARED1:SCIA_IDLE1;
		} else if (spvel <= 140) {
			frame = (m_iFlags & SCIF_SCARED) ? SCIA_WALKSCARED:SCIA_WALK;
		} else if (spvel <= 240) {
			frame = (m_iFlags & SCIF_SCARED) ? SCIA_RUNSCARED:SCIA_RUN;
		}
	}

	runstandardplayerphysics(this);
	Footsteps_Update();

	if (!(flags & FL_ONGROUND) && velocity[2] < -100) {
		if (!(m_iFlags & SCIF_FALLING)) {
			Speak(sci_sndscream[0]);
		}
		m_iFlags |= SCIF_FALLING;
	} else {
		m_iFlags -= (flags & SCIF_FALLING);
	}
}

void monster_scientist::touch(void)
{
	if (other.movetype == MOVETYPE_WALK) {
		velocity = normalize(other.origin - origin) * -128;
	}
}

void monster_scientist::PlayerUse(void)
{
	int r;

	if (m_iFlags & SCIF_FEAR) {
		return;
	}
	if ((m_eUser == world)) {
		if (!(m_iFlags & SCIF_USED)) {
			m_iFlags |= SCIF_USED;
		}

		r = floor(random(0,sci_snduse.length));
		Speak(sci_snduse[r]);

		m_eUser = eActivator;
		m_eRescuer = m_eUser;
		m_vecLastUserPos = m_eUser.origin;
	} else {
		r = floor(random(0,sci_snduseno.length));
		Speak(sci_snduseno[r]);

		m_eUser = world;
	}
}

void monster_scientist::vPain(int iHitBody)
{
	
	WarnOthers();

	if (m_flPainTime > time) {
		return;
	}

	if (random() < 0.25f) {
		return;
	}

	int rand = floor(random(0,sci_sndpain.length));
	Speak(sci_sndpain[rand]);

	frame = SCIA_FLINCH + floor(random(0, 5));
	m_iFlags |= SCIF_FEAR;

	m_flPainTime = time + 0.25f;
}

void monster_scientist::vDeath(int iHitBody)
{
	int r;
	r = floor(random(0,sci_snddie.length));
	Speak(sci_snddie[r]);

	WarnOthers();

	think = Respawn;
	nextthink = time + 10.0f;

	m_eUser = world;
	customphysics = __NULL__;
	m_iFlags = 0x0;

	if (health < -50) {
		Gib();
		return;
	}

	movetype = MOVETYPE_NONE;
	solid = SOLID_CORPSE;
	//takedamage = DAMAGE_NO;

	if (style != SCI_DEAD) {
		frame = SCIA_DIE_SIMPLE + floor(random(0, 6));
		style = SCI_DEAD;
	}
}

void monster_scientist::Hide(void)
{
	setmodel(this, "");
	m_eUser = world;
	solid = SOLID_NOT;
	movetype = MOVETYPE_NONE;
	customphysics = __NULL__;
}

void monster_scientist::Respawn(void)
{
	v_angle[0] = Math_FixDelta(m_oldAngle[0]);
	v_angle[1] = Math_FixDelta(m_oldAngle[1]);
	v_angle[2] = Math_FixDelta(m_oldAngle[2]);

	setorigin(this, m_oldOrigin);
	angles = v_angle;
	solid = SOLID_SLIDEBOX;
	movetype = MOVETYPE_WALK;
	setmodel(this, m_oldModel);
	setsize(this, VEC_HULL_MIN + [0,0,36], VEC_HULL_MAX + [0,0,36]);
	m_eUser = world;
	takedamage = DAMAGE_YES;
	iBleeds = TRUE;
	style = SCI_IDLE;
	customphysics = Physics;
	frame = SCIA_IDLE1;
	health = 50;
	velocity = [0,0,0];
	m_iFlags = 0x0;
	
	if (autocvar_sh_scialert) {
		m_iFlags |= SCIF_FEAR;
	}
}

void monster_scientist::monster_scientist(void)
{
	for (int i = 0; i < sci_sndpain.length; i++) {
		precache_sound(sci_sndpain[i]);
	}
	for (int i = 0; i < sci_snddie.length; i++) {
		precache_sound(sci_snddie[i]);
	}
	for (int i = 0; i < sci_sndscream.length; i++) {
		precache_sound(sci_sndscream[i]);
	}
	for (int i = 0; i < sci_snduse.length; i++) {
		precache_sound(sci_snduse[i]);
	}
	for (int i = 0; i < sci_snduseno.length; i++) {
		precache_sound(sci_snduseno[i]);
	}
	for (int i = 0; i < sci_sndsee.length; i++) {
		precache_sound(sci_sndsee[i]);
	}

	model = "models/scientist.mdl";
	CBaseEntity::CBaseEntity();
	precache_model(m_oldModel);
	Respawn();

	/* This stuff needs to be persistent because we can't guarantee that
	 * the client-side geomset refresh happens. Don't shove this into Respawn */
	colormod[0] = floor(random(1,5));
	switch (colormod[0]) {
		case 1:
			m_flPitch = 105; // Walter
			break;
		case 2:
			m_flPitch = 100; // Einstein
			break;
		case 3:
			m_flPitch = 95; // Luther
			skin = 1;
			break;
		default:
			m_flPitch = 100; // Slick
	}
}

CLASSEXPORT(qreate_arcade, monster_scientist)
