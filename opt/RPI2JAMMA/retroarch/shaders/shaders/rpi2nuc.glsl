#define LUMINOSITE_SCANLINE 0.5
#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif
uniform vec2 TextureSize;
varying COMPAT_PRECISION vec2 TEX0;
#if defined(VERTEX)
uniform mat4 MVPMatrix;
attribute vec4 VertexCoord;
attribute vec2 TexCoord;
void main()
{
	TEX0 = TexCoord;
	gl_Position = MVPMatrix * VertexCoord;
}
#elif defined(FRAGMENT)
uniform sampler2D Texture;
void main()
{
	vec2 texcoord = TEX0;
	vec2 texcoordInPixels = texcoord * TextureSize - vec2(0.5);
	float yCoord = (floor(texcoordInPixels.y) + 0.5) / TextureSize.y;
	vec2 tc1 = vec2(texcoord.x, yCoord);
	vec3 colour1 = texture2D(Texture, tc1).rgb;
	vec3 colour2 = colour1 * vec3(LUMINOSITE_SCANLINE);
	if(fract(texcoordInPixels.y)<0.5) gl_FragColor = vec4(colour1, 1.0); else gl_FragColor = vec4(colour2, 1.0);
}
#endif
