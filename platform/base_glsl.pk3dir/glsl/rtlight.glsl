//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Code for all the dynamic light passes. The renderer is not aware of any
// surface properties beyond diffuse, normal and specularity.
// Alpha-masked surfaces suffer greatly because of this.
//
// diffusemap = albedo (rgba)
// normalmap = normal (rgb), reflectmask (a)
//==============================================================================

!!ver 100 300
!!permu BUMP
!!permu FRAMEBLEND
!!permu SKELETAL
!!permu FOG
!!permu UPPERLOWER

!!cvardf r_glsl_pcf
!!samps diffuse
!!samps =BUMP normalmap reflectcube
!!samps =PCF shadowmap
!!samps =CUBE projectionmap
!!samps =UPPERLOWER upper

!!cvardf r_skipDiffuse

#include "sys/defs.h"

//if there's no vertex normals known, disable some stuff.
//FIXME: this results in dupe permutations.
#ifdef NOBUMP
	#undef SPECULAR
	#undef BUMP
#endif

varying vec2 tex_c;
varying vec3 lightvector;

#define VERTEXCOLOURS

#if defined(VERTEXCOLOURS)
	varying vec4 vc;
#endif

#ifdef BUMP
	varying vec3 eyevector;
	varying mat3 invsurface;
#endif

#if defined(PCF) || defined(CUBE) || defined(SPOT) || defined(ORTHO)
	varying vec4 vtexprojcoord;
#endif

#ifdef VERTEX_SHADER
	#include "sys/skeletal.h"

	void main ()
	{
		vec3 n, s, t, w;
		gl_Position = skeletaltransform_wnst(w,n,s,t);
		n = normalize(n);
		s = normalize(s);
		t = normalize(t);
		tex_c = v_texcoord;
	#ifdef ORTHO
		vec3 lightminusvertex = -l_lightdirection;
		lightvector.x = dot(lightminusvertex, s.xyz);
		lightvector.y = dot(lightminusvertex, t.xyz);
		lightvector.z = dot(lightminusvertex, n.xyz);
	#else
		vec3 lightminusvertex = l_lightposition - w.xyz;
		#ifdef NOBUMP
			lightvector = lightminusvertex;
		#else
			// light direction relative to the surface normal, for bumpmapping.
			lightvector.x = dot(lightminusvertex, s.xyz);
			lightvector.y = dot(lightminusvertex, t.xyz);
			lightvector.z = dot(lightminusvertex, n.xyz);
		#endif
	#endif

	#if defined(VERTEXCOLOURS)
		vc = v_colour;
	#endif

	#ifdef BUMP
		vec3 eyeminusvertex = e_eyepos - w.xyz;
		eyevector.x = dot(eyeminusvertex, s.xyz);
		eyevector.y = dot(eyeminusvertex, t.xyz);
		eyevector.z = dot(eyeminusvertex, n.xyz);
		invsurface = mat3(v_svector, v_tvector, v_normal);
	#endif

	#if defined(PCF) || defined(SPOT) || defined(CUBE) || defined(ORTHO)
		//for texture projections/shadowmapping on dlights
		vtexprojcoord = (l_cubematrix*vec4(w.xyz, 1.0));
	#endif
}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	#include "sys/pcf.h"

	void main ()
	{
	#ifdef ORTHO
		float colorscale = 1.0;
	#else
		float colorscale = max(1.0 - (dot(lightvector, lightvector)/(l_lightradius*l_lightradius)), 0.0);
	#endif

	/* filter the light by the shadowmap. logically a boolean, but we allow fractions for softer shadows */
	#ifdef PCF
		colorscale *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif

	/* filter the colour by the spotlight. discard anything behind the light so we don't get a mirror image */
	#if defined(SPOT)
		if (vtexprojcoord.w < 0.0)
			discard;

		vec2 spot = ((vtexprojcoord.st)/vtexprojcoord.w);
		colorscale*=1.0-(dot(spot,spot));
	#endif

	#if defined(FLAT)
		vec4 bases = vec4(FLAT, FLAT, FLAT, 1.0);
	#else
		#if r_skipDiffuse == 0
			vec4 bases = texture2D(s_diffuse, tex_c);
		#else
			vec4 bases = vec4(1.0, 1.0, 1.0, 1.0);
		#endif
	#endif

	#ifdef BUMP
		vec3 normal_f = normalize(texture2D(s_normalmap, tex_c).rgb - 0.5) * 2.0;
		float refl = 1.0 - texture2D(s_normalmap, tex_c).a;
	#endif

	#ifdef NOBUMP
		// surface can only support ambient lighting, even for lights that try to avoid it.
		vec3 diff = bases.rgb * (l_lightcolourscale.x + l_lightcolourscale.y);
	#else
		vec3 nl = normalize(lightvector);
		#ifdef BUMP
			vec3 diff = bases.rgb * (l_lightcolourscale.x + l_lightcolourscale.y * max(dot(normal_f, nl), 0.0));
		#else
			//we still do bumpmapping even without normal_f to ensure colours are always sane. light.exe does it too.
			vec3 diff = bases.rgb * (l_lightcolourscale.x + l_lightcolourscale.y * max(dot(vec3(0.0, 0.0, 1.0), nl), 0.0));
		#endif
	#endif

	/* respect the reflectcube surface */
	#ifdef BUMP
		vec3 rtc = reflect(-eyevector, normal_f);
		rtc = rtc.x * invsurface[0] + rtc.y * invsurface[1] + rtc.z * invsurface[2];
		rtc = (m_model * vec4(rtc.xyz,0.0)).xyz;
		diff += textureCube(s_reflectcube, rtc).rgb * refl;
	#endif

	/* filter the colour by the cubemap projection */
	#ifdef CUBE
		diff *= textureCube(s_projectionmap, vtexprojcoord.xyz).rgb;
	#endif

		diff.rgb *= bases.a;

		diff *= colorscale * l_lightcolour;
		diff.rgb *= vc.a;

		#if defined(UPPERLOWER)
			diff.rgb *= texture2D(s_upper, tex_c * 4.0).rgb;
		#endif

		gl_FragColor = vec4(fog3additive(diff), vc.a);
	}
#endif
