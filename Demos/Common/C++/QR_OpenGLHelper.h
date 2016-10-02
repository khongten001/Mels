/**************************************************************************************************
 * ==> QR_OpenGLHelper ---------------------------------------------------------------------------*
 **************************************************************************************************
 * Description : Provides common basic tools to work with OpenGL, as e.g. enabling or disabling   *
 *               OpenGL, or drawing a vertex buffer                                               *
 * Developer   : Jean-Milost Reymond                                                              *
 * Copyright   : 2015 - 2016, this file is part of the Mels library, all right reserved           *
 **************************************************************************************************/

#ifndef QR_OpenGLHelperH
#define QR_OpenGLHelperH

// vcl
#include <Vcl.Graphics.hpp>

// Mels library
#include <UTQR3D.hpp>
#include <UTQRGeometry.hpp>

// opengl
#ifdef USE_SHADER
    #ifndef QR_Shader_OpenGL
        #define GLEW_STATIC
        #include "glew.h"
        #include <gl\gl.h>
        #include <gl\glu.h>
    #endif
#else
    #include <gl\gl.h>
    #include <gl\glu.h>
#endif

/**
* OpenGL helper, provides common basic tools to work with OpenGL
*@author Jean-Milost Reymond
*/
class QR_OpenGLHelper
{
    public:
        QR_OpenGLHelper();
        virtual ~QR_OpenGLHelper();

        /**
        * Enables OpenGL
        *@param hWnd - control or form hanle on which OpenGL scene will be drawn
        *@param hDC[out] - device context to use to draw OpenGL scene
        *@param hRC[out] - newly created OpenGL context
        *@return true on success, otherwise false
        */
        static bool EnableOpenGL(HWND hWnd, HDC& hDC, HGLRC& hRC);

        /**
        * Disables OpenGL and clears memory
        *@param hWnd - control or form hanle on which OpenGL scene was drawn
        *@param hDC - device context used to draw OpenGL scene
        *@param hRC - OpenGL context to shutdown
        */
        static void DisableOpenGL(HWND hWnd, HDC hDC, HGLRC hRC);

        /**
        * Sets pixel format to use with OpenGL
        *@param hDC - device context used to draw OpenGL scene
        *@return true on success, otherwise false
        */
        static bool SetPixelFormat(HDC hDC);

        /**
        * Creates OpenGL viewport
        *@param clientWidth - form client width
        *@param clientHeight - form client height
        *@param createPerspective - if true, perspective matrix will also be created
        */
        static void CreateViewport(int clientWidth, int clientHeight, bool createPerspective);

        /**
        * Gets frustum projection matrix (glFrustum() OpenGL equivalent)
        *@param left - viewport left edge
        *@param right - viewport right edge
        *@param bottom - viewport bottom edge
        *@param top - viewport top edge
        *@param zNear - near clipping plane
        *@param zFar - far clipping plane
        *@return matrix
        */
        static TQRMatrix4x4 GetFrustum(float left,
                                       float right,
                                       float bottom,
                                       float top,
                                       float zNear,
                                       float zFar);

        /**
        * Gets projection (or camera) matrix
        *@param fov - field of view, in degrees
        *@param width - view width, generally the same as window width
        *@param height - view height, generally the same as window height
        *@param zNear - near plane clipping
        *@param zFar - far plane clipping
        *@return matrix
        *@note This function returns the exactly same matrix as gluPerspective
        */
        static TQRMatrix4x4 GetProjection(float fov,
                                          float width,
                                          float height,
                                          float zNear,
                                          float zFar);

        /**
        * Creates combined look at matrix (left hand system)
        *@param position - eye (or camera) target position
        *@param direction - eye (or camera) direction vector
        *@param up - up vector direction
        *@return look at matrix
        */
        static TQRMatrix4x4 LookAtLH(TQRVector3D& position,
                                     TQRVector3D& direction,
                                     TQRVector3D& up);

        /**
        * Creates combined look at matrix (right hand system)
        *@param position - eye (or camera) target position
        *@param direction - eye (or camera) direction vector
        *@param up - up vector direction
        *@return look at matrix
        */
        static TQRMatrix4x4 LookAtRH(TQRVector3D& position,
                                     TQRVector3D& direction,
                                     TQRVector3D& up);

        /**
        * Converts mouse position to OpenGL point (i.e. a point in the OpenGL space)
        *@param hWnd - handle of the window or control on which mouse is hoving
        *@param viewRect - OpenGL view rectangle
        */
        static TQRVector3D MousePosToGLPoint(HWND hWnd, TQRRect& viewRect);

        /**
        * Copies the current OpenGL rendering into a bitmap
        *@param pBitmap - bitmap to copy to
        */
        static void GetBitmapFromOpenGL(TBitmap* pBitmap);

        /**
        * Converts bitmap in pixels byte array
        *@param pBitmap - bitmap to convert
        *@param[out] pPixels - pixels array when function returns, user is responsible to delete it
        *@param flipY - if true, image will be mirrored on the Y axis
        *@param bgr - if true, image will be converted from RGB to BGR (or RGBA to ABGR) format
        *@return true on success, otherwise false
        */
        static bool BytesFromBitmap(TBitmap* pBitmap, BYTE*& pPixels, bool flipY, bool bgr);

        /**
        * Creates texture
        *@param width - texture width
        *@param height - texture height
        *@param format - texture format, can be GL_RGB or GL_RGBA
        *@param pPixels - texture pixels array
        *@param minFiltter - min filter to apply
        *@param magFilter - mag filter to apply
        *@param targetID - OpenGL target identigier, e.g. GL_TEXTURE_2D
        *@return newly created texture identifier
        */
        static int CreateTexture(WORD   width,
                                 WORD   height,
                                 WORD   format,
                                 void*  pPixels,
                                 GLuint minFilter,
                                 GLuint magFilter,
                                 GLuint targetID);

        /**
        * Gets shader uniform hnadle
        *@param pShader - shader containing uniform to get
        *@param uniform - uniform to get from shader
        *@return uniform handle, -1 if not found or on error
        */
        #ifdef USE_SHADER
            static GLint GetUniform(TQRShader* pShader, EQRShaderAttribute uniform);
        #endif

        /**
        * Gets shader attribute
        *@param pShader - shader containing attribute to get
        *@param attribute - attribute to get from shader
        *@return uniform handle, -1 if not found or on error
        */
        #ifdef USE_SHADER
            static GLint GetAttribute(TQRShader* pShader, EQRShaderAttribute attribute);
        #endif

        /**
        * Draws a mesh using OpenGL
        *@param mesh - mesh to draw
        *@param translation - translation to apply to mesh
        *@param rotationX - rotation on x axis to apply to mesh
        *@param rotationY - rotation on y axis to apply to mesh
        *@param rotationZ - rotation on z axis to apply to mesh
        *@param scale - scaling to apply to mesh
        *@param textures - model textures
        */
        static void Draw(const TQRMesh&     mesh,
                         const TQRVector3D& translation,
                               float        rotationX,
                               float        rotationY,
                               float        rotationZ,
                         const TQRVector3D& scale,
                         const TQRTextures& textures);

        /**
        * Draws a mesh using OpenGL
        *@param mesh - mesh to draw
        *@param modelMatrix - model matrix to apply to mesh
        *@param textures - model textures
        */
        static void Draw(const TQRMesh&      mesh,
                         const TQRMatrix4x4& modelMatrix,
                         const TQRTextures&  textures);

        /**
        * Draws a mesh using OpenGL and shader
        *@param mesh - mesh to draw
        *@param modelMatrix - model matrix to apply to mesh
        *@param textures - model textures
        *@param pShader - shader that will be used to draw the model
        *@return true on success, otherwise false
        */
        #ifdef USE_SHADER
            static bool Draw(const TQRMesh&      mesh,
                             const TQRMatrix4x4& modelMatrix,
                             const TQRTextures&  textures,
                                   TQRShader*    pShader);
        #endif

        /**
        * Draws a mesh using OpenGL and shader
        *@param mesh - mesh to draw
        *@param nextMesh - mesh to interpolate with
        *@param modelMatrix - model matrix to apply to mesh
        *@param interpolationFactor - interpolation factor
        *@param textures - model textures
        *@param pShader - shader that will be used to draw the model
        *@return true on success, otherwise false
        */
        #ifdef USE_SHADER
            static bool Draw(const TQRMesh&      mesh,
                             const TQRMesh&      nextMesh,
                             const TQRMatrix4x4& modelMatrix,
                                   float         interpolationFactor,
                             const TQRTextures&  textures,
                                   TQRShader*    pShader);
        #endif

        /**
        * Selects texture to draw
        *@param textures - model texture list
        *@param modelName - model name to draw (should match with a texture name in the list)
        */
        static void SelectTexture(const TQRTextures& textures, const UnicodeString& modelName);

        /**
        * Selects texture to draw
        *@param pShader - shader that will draw the texture
        *@param textures - model texture list
        *@param modelName - model name to draw (should match with a texture name in the list)
        */
        #ifdef USE_SHADER
            static void SelectTexture(      TQRShader*     pShader,
                                      const TQRTextures&   textures,
                                      const UnicodeString& modelName);
        #endif
};

#endif