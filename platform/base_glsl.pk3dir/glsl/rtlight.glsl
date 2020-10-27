//======= Copyright (c) 2015-2020 Vera Visions LLC. All rights reserved. =======
//
// Purpose: 
//
// Code for all the dynamic light passes. The renderer is not aware of any
// surface properties beyond diffuse, normal and specularity.
// Alpha-masked surfaces suffer greatly because of this.
//==============================================================================

!!ver 100 300
!!permu BUMP
!!permu FRAMEBLEND
!!permu SKELETAL
!!permu FOG
!!permu REFLECTCUBEMASK
!!cvarf r_glsl_offsetmapping_scale
!!cvardf r_glsl_pcf
!!samps diffuse normalmap specular upper lower reflectcube reflectmask
!!samps =PCF shadowmap
!!samps =CUBE projectionmap
!!cvardf r_skipNormal

#include "sys/defs.h"

//this is the main shader responsible for realtime dlights.

//texture units:
//s0=diffuse, s1=normal, s2=specular, s3=shadowmap
//custom modifiers:
//PCF(shadowmap)
//CUBEPROJ(projected cubemap)
//SPOT(projected circle
//CUBESHADOW

#if 0 && defined(GL_ARB_texture_gather) && defined(PCF) 
#extension GL_ARB_texture_gather : enable
#endif

//if there's no vertex normals known, disable some stuff.
//FIXME: this results in dupe permutations.
#ifdef NOBUMP
#undef SPECULAR
#undef BUMP
#endif

	varying vec2 tex_c;
	varying vec3 lightvector;
	#if defined(VERTEXCOLOURS)
		varying vec4 vc;
	#endif
	#if defined(SPECULAR) || defined(REFLECTCUBEMASK)
		varying vec3 eyevector;
	#endif
	#ifdef REFLECTCUBEMASK
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
	tex_c = v_texcoord;	//pass the texture coords straight through
#ifdef ORTHO
	vec3 lightminusvertex = -l_lightdirection;
	lightvector.x = dot(lightminusvertex, s.xyz);
	lightvector.y = dot(lightminusvertex, t.xyz);
	lightvector.z = dot(lightminusvertex, n.xyz);
#else
	vec3 lightminusvertex = l_lightposition - w.xyz;
	#ifdef NOBUMP
		//the only important thing is distance
		lightvector = lightminusvertex;
	#else
		//the light direction relative to the surface normal, for bumpmapping.
		lightvector.x = dot(lightminusvertex, s.xyz);
		lightvector.y = dot(lightminusvertex, t.xyz);
		lightvector.z = dot(lightminusvertex, n.xyz);
	#endif
#endif
#if defined(VERTEXCOLOURS)
	vc = v_colour;
#endif
#if defined(SPECULAR) || defined(REFLECTCUBEMASK)
	vec3 eyeminusvertex = e_eyepos - w.xyz;
	eyevector.x = dot(eyeminusvertex, s.xyz);
	eyevector.y = dot(eyeminusvertex, t.xyz);
	eyevector.z = dot(eyeminusvertex, n.xyz);
#endif
#ifdef REFLECTCUBEMASK
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
#ifdef PCF
	/*filter the light by the shadowmap. logically a boolean, but we allow fractions for softer shadows*/
	colorscale *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
#endif
#if defined(SPOT)
	/*filter the colour by the spotlight. discard anything behind the light so we don't get a mirror image*/
	if (vtexprojcoord.w < 0.0) discard;
	vec2 spot = ((vtexprojcoord.st)/vtexprojcoord.w);
	colorscale*=1.0-(dot(spot,spot));
#endif

//read raw texture samples (offsetmapping munges the tex coords first)

#if defined(FLAT)
	vec4 bases = vec4(FLAT, FLAT, FLAT, 1.0);
#else
	vec4 bases = texture2D(s_diffuse, tex_c);
	#ifdef VERTEXCOLOURS
		bases.rgb *= bases.a;
	#endif
#endif

#if defined(BUMP) || defined(SPECULAR) || defined(REFLECTCUBEMASK)

	#if r_skipNormals==1
		vec3 normal_f = normalize(texture2D(s_normalmap, tex_c).rgb - 0.5);
	#else
		#define normal_f vec3(0.0,0.0,0.5)
	#endif

#elif defined(REFLECTCUBEMASK)
	vec3 normal_f = vec3(0.0,0.0,1.0);
#endif
#ifdef SPECULAR
	vec4 specs = texture2D(s_specular, tex_c);
#endif

	#define dielectricSpecular 0.04
	#ifdef SPECULAR
		#ifdef ORM	//pbr-style occlusion+roughness+metalness
			#define occlusion specs.r
			#define roughness clamp(specs.g, 0.04, 1.0)
			#define metalness specs.b
			#define gloss 1.0 //sqrt(1.0-roughness)
			#define ambientrgb (specrgb+col.rgb)
			vec3 specrgb = mix(vec3(dielectricSpecular), bases.rgb, metalness);
			bases.rgb = bases.rgb * (1.0 - dielectricSpecular) * (1.0-metalness);
		#elif defined(SG) //pbr-style specular+glossiness
			//occlusion needs to be baked in. :(
			#define roughness (1.0-specs.a)
			#define gloss specs.a
			#define specrgb specs.rgb
			#define ambientrgb (specs.rgb+col.rgb)
		#else   //blinn-phong
			#define roughness (1.0-specs.a)
			#define gloss specs.a
			#define specrgb specs.rgb
			#define ambientrgb col.rgb
		#endif
	#else
		#define roughness 0.3
		#define specrgb 1.0 //vec3(dielectricSpecular)
	#endif

	vec3 diff;
	#ifdef NOBUMP
		//surface can only support ambient lighting, even for lights that try to avoid it.
		diff = bases.rgb * (l_lightcolourscale.x+l_lightcolourscale.y);
	#else
		vec3 nl = normalize(lightvector);
		#ifdef BUMP
			diff = bases.rgb * (l_lightcolourscale.x + l_lightcolourscale.y * max(dot(normal_f, nl), 0.0));
		#else
			//we still do bumpmapping even without normal_f to ensure colours are always sane. light.exe does it too.
			diff = bases.rgb * (l_lightcolourscale.x + l_lightcolourscale.y * max(dot(vec3(0.0, 0.0, 1.0), nl), 0.0));
		#endif
	#endif
	#ifdef SPECULAR
		vec3 halfdir = normalize(normalize(eyevector) + nl);
		float spec = pow(max(dot(halfdir, normal_f), 0.0), FTE_SPECULAR_EXPONENT * gloss)*float(SPECMUL);
		diff += l_lightcolourscale.z * spec * specrgb;
	#endif

#ifdef REFLECTCUBEMASK
	vec3 rtc = reflect(-eyevector, normal_f);
	rtc = rtc.x*invsurface[0] + rtc.y*invsurface[1] + rtc.z*invsurface[2];
	rtc = (m_model * vec4(rtc.xyz,0.0)).xyz;
	diff += texture2D(s_reflectmask, tex_c).rgb * textureCube(s_reflectcube, rtc).rgb;
#endif

#ifdef CUBE
	/*filter the colour by the cubemap projection*/
	diff *= textureCube(s_projectionmap, vtexprojcoord.xyz).rgb;
#endif

#if defined(PROJECTION)
	/*2d projection, not used*/
//	diff *= texture2d(s_projectionmap, shadowcoord);
#endif
#if defined(occlusion) && !defined(NOOCCLUDE)
	diff *= occlusion;
#endif
#if defined(VERTEXCOLOURS)
	diff *= vc.rgb * vc.a;
#endif

	diff *= colorscale*l_lightcolour;
	gl_FragColor = vec4(fog3additive(diff), 1.0);
}
#endif

