#include "baseColor.glsl"
#include "specular.glsl"
#include "emissive.glsl"
#include "occlusion.glsl"
#include "normal.glsl"
#include "metallic.glsl"
#include "roughness.glsl"
#include "shininess.glsl"

#include "../material.glsl"

/*
author: Patricio Gonzalez Vivo
description: Material Constructor. Designed to integrate with GlslViewer's defines https://github.com/patriciogonzalezvivo/glslViewer/wiki/GlslViewer-DEFINES#material-defines 
use: 
    - void materialNew(out <material> _mat)
    - <material> materialNew()
options:
    - SURFACE_POSITION
    - SHADING_SHADOWS
    - MATERIAL_CLEARCOAT_THICKNESS
    - MATERIAL_CLEARCOAT_ROUGHNESS
    - MATERIAL_CLEARCOAT_THICKNESS_NORMAL
    - SHADING_MODEL_SUBSURFACE
    - MATERIAL_SUBSURFACE_COLOR
    - SHADING_MODEL_CLOTH
license: |
    Copyright (c) 2021 Patricio Gonzalez Vivo.
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.    
*/

#ifndef SURFACE_POSITION
#if defined(GLSLVIEWER)
#define SURFACE_POSITION v_position
#else
#define SURFACE_POSITION vec3(0.0)
#endif
#endif

#ifndef SHADOW_INIT
#if defined(LIGHT_SHADOWMAP) && defined(LIGHT_SHADOWMAP_SIZE) && defined(LIGHT_COORD)
#define SHADOW_INIT shadow(LIGHT_SHADOWMAP, vec2(LIGHT_SHADOWMAP_SIZE), (LIGHT_COORD).xy, (LIGHT_COORD).z)
#else
#define SHADOW_INIT 1.0
#endif
#endif


#ifndef FNC_MATERIAL_NEW
#define FNC_MATERIAL_NEW

void materialNew(out Material _mat) {
    // Surface data
    _mat.position           = (SURFACE_POSITION).xyz;
    _mat.normal             = materialNormal();

    // PBR Properties
    _mat.baseColor          = materialBaseColor();
    _mat.emissive           = materialEmissive();
    _mat.roughness          = materialRoughness();
    _mat.metallic           = materialMetallic();

    // Other Properties
    _mat.f0                 = vec3(0.04);
    _mat.reflectance        = 0.5;

    // Shade
    _mat.ambientOcclusion   = materialOcclusion();

    _mat.shadow             = SHADOW_INIT;

    // Clear Coat Model
#if defined(MATERIAL_CLEARCOAT_THICKNESS)
    _mat.clearCoat  = MATERIAL_CLEARCOAT_THICKNESS;
    _mat.clearCoatRoughness = MATERIAL_CLEARCOAT_ROUGHNESS;
#if defined(MATERIAL_CLEARCOAT_THICKNESS_NORMAL)
    _mat.clearCoatNormal    = vec3(0.0, 0.0, 1.0);
#endif
#endif

    // SubSurface Model
#if defined(SHADING_MODEL_SUBSURFACE)
    _mat.thickness          = 0.5;
    _mat.subsurfacePower    = 12.234;
#endif

#if defined(MATERIAL_SUBSURFACE_COLOR)
    #if defined(SHADING_MODEL_SUBSURFACE)
    _mat.subsurfaceColor    = vec3(1.0);
    #else
    _mat.subsurfaceColor    = vec3(0.0);
    #endif
#endif

    // Cloath Model
#if defined(SHADING_MODEL_CLOTH)
    _mat.sheenColor         = sqrt(_mat.baseColor.rgb);
#endif
}

Material materialNew() {
    Material mat;
    materialNew(mat);
    return mat;
}

#endif
