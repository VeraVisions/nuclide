!!ver 100 150
!!permu FOG
!!permu BUMP
!!permu DELUXE
!!permu SPECULAR
!!permu FULLBRIGHT
!!permu FAKESHADOWS
!!permu OFFSETMAPPING
!!permu REFLECTCUBEMASK
!!permu LIGHTSTYLED
!!samps diffuse
!!samps !VERTEXLIT lightmap
!!samps =BUMP normalmap
!!samps =DELUXE deluxemap
!!samps =SPECULAR specular
!!samps =FULLBRIGHT fullbright
!!samps =LIGHTSTYLED lightmap1 lightmap2 lightmap3
!!samps =LIGHTSTYLED =DELUXE deluxemap1 deluxemap2 deluxemap3
!!samps =FAKESHADOWS shadowmap
!!samps =REFLECTCUBEMASK reflectmask reflectcube
!!cvardf r_glsl_pcf
!!cvarf r_glsl_offsetmapping_scale
!!cvardf r_skipDiffuse
!!cvardf r_skipNormal
!!cvardf r_skipSpecular
!!cvardf r_skipLightmap

#ifndef FRESNEL
#define FRESNEL 0.25f
#endif

#include "sys/defs.h"

varying vec2 tex_c;

#ifdef BUMP
varying vec3 eyevector;
varying mat3 invsurface;
#define PBR
#endif

varying vec2 lm0;
#ifdef LIGHTSTYLED
varying vec2 lm1, lm2, lm3;
#endif

#ifdef FAKESHADOWS
	varying vec4 vtexprojcoord;
#endif

#ifdef VERTEX_SHADER
	#ifndef VERTEXLIT
	void lightmapped_init(void)
	{
		lm0 = v_lmcoord;
		#ifdef LIGHTSTYLED
		lm1 = v_lmcoord2;
		lm2 = v_lmcoord3;
		lm3 = v_lmcoord4;
		#endif
	}
	#endif
	
	void main (void)
	{
	#ifndef VERTEXLIT
		lightmapped_init();
	#endif

	#ifdef PBR
		invsurface[0] = v_svector;
		invsurface[1] = v_tvector;
		invsurface[2] = v_normal;
		vec3 eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot(eyeminusvertex, v_svector.xyz);
		eyevector.y = dot(eyeminusvertex, v_tvector.xyz);
		eyevector.z = dot(eyeminusvertex, v_normal.xyz);
	#endif

		tex_c = v_texcoord;
		gl_Position = ftetransform();
		
		#ifdef FAKESHADOWS
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
		#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	#include "sys/pcf.h"

	#ifdef OFFSETMAPPING
		#include "sys/offsetmapping.h"
	#endif

	#ifndef VERTEXLIT
#if r_skipLightmap==0
	#ifdef LIGHTSTYLED
		#define LIGHTMAP0 texture2D(s_lightmap0, lm0).rgb
		#define LIGHTMAP1 texture2D(s_lightmap1, lm1).rgb
		#define LIGHTMAP2 texture2D(s_lightmap2, lm2).rgb
		#define LIGHTMAP3 texture2D(s_lightmap3, lm3).rgb
	#else
		#define LIGHTMAP texture2D(s_lightmap, lm0).rgb 
	#endif
#else
	#ifdef LIGHTSTYLED
		#define LIGHTMAP0 vec3(0.5,0.5,0.5)
		#define LIGHTMAP1 vec3(0.5,0.5,0.5)
		#define LIGHTMAP2 vec3(0.5,0.5,0.5)
		#define LIGHTMAP3 vec3(0.5,0.5,0.5)
	#else
		#define LIGHTMAP vec3(0.5,0.5,0.5)
	#endif
#endif

	vec3 lightmap_fragment()
	{
		vec3 lightmaps;

	#ifdef LIGHTSTYLED
		lightmaps  = LIGHTMAP0 * e_lmscale[0].rgb;
		lightmaps += LIGHTMAP1 * e_lmscale[1].rgb;
		lightmaps += LIGHTMAP2 * e_lmscale[2].rgb;
		lightmaps += LIGHTMAP3 * e_lmscale[3].rgb;
	#else
		lightmaps  = LIGHTMAP * e_lmscale.rgb;
	#endif
		return lightmaps;
	}

#if r_skipNormal==0
	vec3 lightmap_fragment(vec3 normal_f)
	{
	#ifndef DELUXE
		return lightmap_fragment();
	#else
		vec3 lightmaps;

	#ifdef LIGHTSTYLED
		lightmaps  = LIGHTMAP0 * e_lmscale[0].rgb * dot(normal_f, texture2D(s_deluxemap0, lm0).rgb);
		lightmaps += LIGHTMAP1 * e_lmscale[1].rgb * dot(normal_f, texture2D(s_deluxemap1, lm1).rgb);
		lightmaps += LIGHTMAP2 * e_lmscale[2].rgb * dot(normal_f, texture2D(s_deluxemap2, lm2).rgb);
		lightmaps += LIGHTMAP3 * e_lmscale[3].rgb * dot(normal_f, texture2D(s_deluxemap3, lm3).rgb);
	#else 
		lightmaps  = LIGHTMAP * e_lmscale.rgb * dot(normal_f, texture2D(s_deluxemap, lm0).rgb);
	#endif

		return lightmaps;
	#endif
	}
#endif
	#endif

	float LightingFuncGGX(vec3 N, vec3 V, vec3 L, float roughness, float F0)
	{
		float alpha = roughness*roughness;

		vec3 H = normalize(V+L);

		float dotNL = clamp(dot(N,L), 0.0, 1.0);
		float dotLH = clamp(dot(L,H), 0.0, 1.0);
		float dotNH = clamp(dot(N,H), 0.0, 1.0);

		float F, D, vis;

		// D
		float alphaSqr = alpha*alpha;
		float pi = 3.14159f;
		float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0f;
		D = alphaSqr/(pi * denom * denom);

		// F
		float dotLH5 = pow(1.0f-dotLH,5);
		F = F0 + (1.0-F0)*(dotLH5);

		// V
		float k = alpha/2.0f;
		float k2 = k*k;
		float invK2 = 1.0f-k2;
		vis = 1.0/(dotLH*dotLH*invK2 + k2);

		float specular = dotNL * D * F * vis;
		return specular;
	}

	void main (void)
	{
	#ifdef OFFSETMAPPING
		vec2 tcoffsetmap = offsetmap(s_normalmap, tex_c, eyevector);
	#else
		#define tcoffsetmap tex_c
	#endif

		/* samplers */
		vec4 albedo_f = texture2D(s_diffuse, tcoffsetmap); // diffuse RGBA
		vec3 normal_f = normalize(texture2D(s_normalmap, tcoffsetmap).rgb - 0.5); // normalmap RGB

		/* deluxe/light */
		vec3 deluxe = normalize(texture2D(s_deluxemap, lm0).rgb);

	#ifdef PBR
		float metalness_f =texture2D(s_specular, tcoffsetmap).r; // specularmap R
		float roughness_f = texture2D(s_specular, tcoffsetmap).g; // specularmap G
		float ao = texture2D(s_specular, tcoffsetmap).b; // specularmap B
		
		/* coords */
		vec3 cube_c;

		/* calculate cubemap texcoords */
		cube_c = reflect(-eyevector, normal_f.rgb);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = (m_model * vec4(cube_c.xyz, 0.0)).xyz;

		gl_FragColor = albedo_f;

		/* do PBR reflection using cubemap */
		gl_FragColor += (metalness_f * textureCube(s_reflectcube, cube_c));

		/* do PBR specular using our handy function */
		gl_FragColor += (LightingFuncGGX(normal_f, normalize(eyevector), deluxe, roughness_f, FRESNEL) * gl_FragColor);
	#else
		gl_FragColor = albedo_f;
	#endif

	#ifndef VERTEXLIT
		/* calculate lightmap fragment on top */
		gl_FragColor.rgb *= lightmap_fragment(normal_f);
	#endif

		/* r_shadows 2 */
	#ifdef FAKESHADOWS
		gl_FragColor.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
	#endif

		/* emissive texture/fullbright bits */
	#ifdef FULLBRIGHT
		vec3 emission_f = texture2D(s_fullbright, tcoffsetmap).rgb; // fullbrightmap RGB
		gl_FragColor.rgb += emission_f;
	#endif

		/* ambient occlusion */
	#ifdef PBR
		gl_FragColor.rgb *= ao;
	#endif

	#if defined(MASK)
	#if defined(MASKLT)
		if (gl_FragColor.a < MASK)
			discard;
	#else
		if (gl_FragColor.a >= MASK)
			discard;
	#endif
		gl_FragColor.a = 1.0;	//alpha blending AND alpha testing usually looks stupid, plus it screws up our fog.
	#endif

		/* and let the engine add fog on top */
		gl_FragColor = fog4(gl_FragColor);
	}
#endif
