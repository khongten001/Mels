{**************************************************************************************************
 * ==> UTQRVCLModelRendererGL --------------------------------------------------------------------*
 **************************************************************************************************
 * Description : This module provides a model renderer based on VCL and OpenGL                    *
 * Developer   : Jean-Milost Reymond                                                              *
 * Copyright   : 2015 - 2016, this file is part of the Mels library, all right reserved           *
 **************************************************************************************************}

unit UTQRVCLModelRendererGL;

interface
    // is compiling on XE4 or earlier?
    {$IF CompilerVersion < 26}
        // do not include XE7.OpenGLExt in hpp, because it may generate conflicts in C++ code
        (*$NOINCLUDE XE7.OpenGLext *)
    {$ELSE}
        // do not include Winapi.OpenGLExt in hpp, because it may generate conflicts in C++ code
        (*$NOINCLUDE Winapi.OpenGLext *)
    {$ENDIF}

uses System.SysUtils,
     UTQRGeometry,
     UTQR3D,
     UTQRHelpers,
     UTQRVCLHelpers,
     UTQRVCLModelRenderer,
     Vcl.Graphics,
     Winapi.Windows,
     // is compiling on XE4 or earlier?
     {$IF CompilerVersion < 26}
         // unfortunately the required OpenGL headers does not exist or are incomplete in XE4 and
         // earlier, so the DelphiGL component (provided with installation) should be used instead
         XE7.OpenGL, XE7.OpenGLext;
     {$ELSE}
         Winapi.OpenGL, Winapi.OpenGLext;
     {$ENDIF}

type
    {**
    * Basic interface to implement a model renderer
    *}
    TQRVCLModelRendererGL = class(TQRVCLModelRenderer)
        protected
            {**
            * Selects texture to draw
            *@param textures - model texture list
            *@param modelName - model name to draw (should match with a texture name in the list)
            *}
            procedure SelectTexture(const textures: TQRTextures;
                                   const modelName: UnicodeString); overload; virtual;

            {**
            * Selects texture to draw
            *@param pShader - shader that will draw the texture
            *@param textures - model texture list
            *@param modelName - model name to draw (should match with a texture name in the list)
            *}
            procedure SelectTexture(const pShader: TQRShader;
                                   const textures: TQRTextures;
                                  const modelName: UnicodeString); overload; virtual;

        public
            {**
            * Constructor
            *}
            constructor Create; override;

            {**
            * Destructor
            *}
            destructor Destroy; override;

            {**
            * Creates a device context and enables OpenGL
            *@param hWnd - control or form handle on which OpenGL scene will be drawn
            *@param doubleBuffered - if true, OpenGL rendering will be double buffered
            *@param hDC[out] - device context to use to draw OpenGL scene
            *@param hRC[out] - newly created OpenGL context
            *@return true on success, otherwise false
            *@note The GDI cannot be used to draw above or below OpenGL scene if double buffering is
            *      enabled. This also means that the control background will be opaque
            *}
            function CreateDCAndEnableOpenGL(hWnd: THandle;
                        doubleBuffered: Boolean;
                          out hDC, hRC: THandle): Boolean; virtual;

            {**
            * Enables OpenGL
            *@param hWnd - control or form handle on which OpenGL scene will be drawn
            *@param doubleBuffered - if true, OpenGL rendering will be double buffered
            *@param hDC - device context to use to draw OpenGL scene
            *@param hRC[out] - newly created OpenGL context
            *@return true on success, otherwise false
            *@note The GDI cannot be used to draw above or below OpenGL scene if double buffering is
            *      enabled. This also means that the control background will be opaque
            *}
            function EnableOpenGL(doubleBuffered: Boolean;
                                             hDC: THandle;
                                         out hRC: THandle): Boolean; virtual;

            {**
            * Disables OpenGL and clears memory
            *@param hWnd - control or form handle on which OpenGL scene was drawn
            *@param hDC - device context used to draw OpenGL scene
            *@param hRC - OpenGL context to shutdown
            *}
            procedure DisableOpenGL(hWnd, hDC, hRC: THandle); virtual;

            {**
            * Gets shader uniform hnadle
            *@param pShader - shader containing uniform to get
            *@param uniform - uniform to get from shader
            *@return uniform handle, -1 if not found or on error
            *}
            function GetUniform(const pShader: TQRShader;
                                      uniform: EQRShaderAttribute): GLint; virtual;

            {**
            * Gets shader attribute
            *@param pShader - shader containing attribute to get
            *@param attribute - attribute to get from shader
            *@return uniform handle, -1 if not found or on error
            *}
            function GetAttribute(const pShader: TQRShader;
                                      attribute: EQRShaderAttribute): GLint; virtual;

            {**
            * Creates OpenGL viewport
            *@param clientWidth - form client width
            *@param clientHeight - form client height
            *}
            procedure CreateViewport(clientWidth, clientHeight: Integer); virtual;

            {**
            * Converts mouse position to OpenGL point (i.e. a point in the OpenGL space)
            *@param hWnd - handle of the window or control on which mouse is hoving
            *@param viewRect - OpenGL view rectangle
            *@return converted point in the OpenGL space
            *}
            function MousePosToGLPoint(hWnd: THandle; out viewRect: TQRRect): TQRVector3D; virtual;

            {**
            * Copies the current OpenGL rendering into a bitmap
            *@param pBitmap - bitmap to copy to
            *}
            procedure GetBitmapFromOpenGL(pBitmap: Vcl.Graphics.TBitmap); virtual;

            {**
            * Creates texture
            *@param width - texture width
            *@param height - texture height
            *@param format - texture format, can be GL_RGB or GL_RGBA
            *@param pPixels - texture pixels array
            *@param minFiltter - min filter to apply
            *@param magFilter - mag filter to apply
            *@param targetID - OpenGL target identigier, e.g. GL_TEXTURE_2D
            *@return newly created texture identifier
            *}
            function CreateTexture(width, height, format: WORD;
                                                 pPixels: Pointer;
                          minFilter, magFilter, targetID: GLuint): GLInt; virtual;

            {**
            * Draws a mesh
            *@param mesh - mesh to draw
            *@param translation - translation to apply to mesh
            *@param rotationX - rotation on x axis to apply to mesh
            *@param rotationY - rotation on y axis to apply to mesh
            *@param rotationZ - rotation on z axis to apply to mesh
            *@param scale - scaling to apply to mesh
            *@param textures - model textures
            *}
            procedure Draw(var mesh: TQRMesh;
                  const translation: TQRVector3D;
                          rotationX,
                          rotationY,
                          rotationZ: Single;
                        const scale: TQRVector3D;
                     const textures: TQRTextures); overload; override;

            {**
            * Draws a mesh
            *@param mesh - mesh to draw
            *@param modelMatrix - model matrix to apply to mesh
            *@param textures - model textures
            *}
            procedure Draw(var mesh: TQRMesh;
                  const modelMatrix: TQRMatrix4x4;
                     const textures: TQRTextures); overload; override;

            {**
            * Draws a mesh using shader
            *@param mesh - mesh to draw
            *@param modelMatrix - model matrix to apply to mesh
            *@param textures - model textures
            *@param pShader - shader that will be used to draw the model
            *@return true on success, otherwise false
            *}
            function Draw(var mesh: TQRMesh;
                 const modelMatrix: TQRMatrix4x4;
                    const textures: TQRTextures;
                           pShader: TQRShader): Boolean; overload; override;

            {**
            * Draws a mesh using shader
            *@param mesh - mesh to draw
            *@param nextMesh - mesh to interpolate with
            *@param modelMatrix - model matrix to apply to mesh
            *@param interpolationFactor - interpolation factor
            *@param textures - model textures
            *@param pShader - shader that will be used to draw the model
            *@return true on success, otherwise false
            *}
            function Draw(var mesh: TQRMesh;
                    const nextMesh: TQRMesh;
                 const modelMatrix: TQRMatrix4x4;
               interpolationFactor: Single;
                    const textures: TQRTextures;
                           pShader: TQRShader): Boolean; overload; override;
    end;

implementation
//--------------------------------------------------------------------------------------------------
// TQRVCLModelRendererGL
//--------------------------------------------------------------------------------------------------
constructor TQRVCLModelRendererGL.Create;
begin
    inherited Create;
end;
//--------------------------------------------------------------------------------------------------
destructor TQRVCLModelRendererGL.Destroy;
begin
    inherited Destroy;
end;
//--------------------------------------------------------------------------------------------------
procedure TQRVCLModelRendererGL.SelectTexture(const textures: TQRTextures;
                                             const modelName: UnicodeString);
var
    index:           NativeInt;
    textureCount, i: NativeUInt;
begin
    textureCount := Length(textures);

    // do draw textures?
    if (textureCount = 0) then
    begin
        glDisable(GL_TEXTURE_2D);
        Exit;
    end;

    index := -1;

    // iterate through textures belonging to model
    for i := 0 to textureCount - 1 do
        // found a texture to draw?
        if (Assigned(textures[i]) and (textures[i].Enabled) and (textures[i].Name = modelName)) then
        begin
            // get texture index
            index := i;
            break;
        end;

    // found texture index to draw?
    if (index >= 0) then
    begin
        // draw texture
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, textures[index].Index);
        Exit;
    end;

    glDisable(GL_TEXTURE_2D);
end;
//--------------------------------------------------------------------------------------------------
procedure TQRVCLModelRendererGL.SelectTexture(const pShader: TQRShader;
                                             const textures: TQRTextures;
                                            const modelName: UnicodeString);
var
    uniform:         GLint;
    index:           NativeInt;
    textureCount, i: NativeUInt;
begin
    // get color map slot from shader
    uniform := GetUniform(pShader, EQR_SA_ColorMap);

    // found it?
    if (uniform = -1) then
        // nothing to do (some shader may have no texture to handle)
        Exit;

    textureCount := Length(textures);

    // do draw textures?
    if (textureCount = 0) then
    begin
        glDisable(GL_TEXTURE_2D);
        Exit;
    end;

    index := -1;

    // iterate through textures belonging to model
    for i := 0 to textureCount do
        // found a texture to draw?
        if (Assigned(textures[i]) and (textures[i].Enabled) and (textures[i].Name = modelName)) then
        begin
            // get texture index
            index := i;
            break;
        end;

    // found texture index to draw?
    if (index >= 0) then
    begin
        // draw texture
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, textures[index].Index);
        glActiveTexture(GL_TEXTURE0);
        Exit;
    end;

    glDisable(GL_TEXTURE_2D);
end;
//--------------------------------------------------------------------------------------------------
function TQRVCLModelRendererGL.CreateDCAndEnableOpenGL(hWnd: THandle;
                                             doubleBuffered: Boolean;
                                               out hDC, hRC: THandle): Boolean;
begin
    // no window handle?
    if (hWnd = 0) then
    begin
        Result := False;
        Exit;
    end;

    // get the device context (DC)
    hDC := GetDC(hWnd);

    // failed to get device context?
    if (hDC = 0) then
    begin
        Result := False;
        Exit;
    end;

    // device context is created, now enable OpenGL
    Result := EnableOpenGL(doubleBuffered, hDC, hRC);
end;
//--------------------------------------------------------------------------------------------------
function TQRVCLModelRendererGL.EnableOpenGL(doubleBuffered: Boolean;
                                                       hDC: THandle;
                                                   out hRC: THandle): Boolean;
begin
    // failed to get device context?
    if (hDC = 0) then
    begin
        Result := False;
        Exit;
    end;

    // configure pixel format
    if (not SetTargetPixelFormat(hDC, doubleBuffered)) then
    begin
        Result := False;
        Exit;
    end;

    // create OpenGL render context
    hRC := wglCreateContext(hDC);

    // succeeded?
    if (hRC = 0) then
    begin
        Result := False;
        Exit;
    end;

    // make render context as OpenGL current context
    if (not wglMakeCurrent(hDC, hRC)) then
    begin
        Result := False;
        Exit;
    end;

    Result := True;
end;
//--------------------------------------------------------------------------------------------------
procedure TQRVCLModelRendererGL.DisableOpenGL(hWnd, hDC, hRC: THandle);
begin
    // disable and delete OpenGL context
    if (hRC <> 0) then
    begin
        wglMakeCurrent(0, 0);
        wglDeleteContext(hRC);
    end;

    // delete device context
    if ((hWnd <> 0) and (hDC <> 0)) then
        ReleaseDC(hWnd, hDC);
end;
//--------------------------------------------------------------------------------------------------
function TQRVCLModelRendererGL.GetUniform(const pShader: TQRShader;
                                                uniform: EQRShaderAttribute): GLint;
var
    propertyName: AnsiString;
begin
    // no shader?
    if (not Assigned(pShader)) then
    begin
        Result := -1;
        Exit;
    end;

    // get uniform property name
    propertyName := AnsiString(pShader.GetAttributeName(uniform));

    // found it?
    if (Length(propertyName) = 0) then
    begin
        Result := -1;
        Exit;
    end;

    // get model matrix slot from shader
    Result := glGetUniformLocation(pShader.GetProgramID(), PAnsiChar(propertyName));
end;
//--------------------------------------------------------------------------------------------------
function TQRVCLModelRendererGL.GetAttribute(const pShader: TQRShader;
                                                attribute: EQRShaderAttribute): GLint;
var
    propertyName: AnsiString;
begin
    // no shader?
    if (not Assigned(pShader)) then
    begin
        Result := -1;
        Exit;
    end;

    // get attribute property name
    propertyName := AnsiString(pShader.GetAttributeName(attribute));

    // found it?
    if (Length(propertyName) = 0) then
    begin
        Result := -1;
        Exit;
    end;

    // get shader interpolation position attribute
    Result := glGetAttribLocation(pShader.GetProgramID(), PAnsiChar(propertyName));
end;
//--------------------------------------------------------------------------------------------------
procedure TQRVCLModelRendererGL.CreateViewport(clientWidth, clientHeight: Integer);
begin
    // invalid width?
    if (clientWidth = 0) then
        clientWidth := 1;

    // invalid height?
    if (clientHeight = 0) then
        clientHeight := 1;

    // set viewport
    glViewport(0, 0, clientWidth, clientHeight);
end;
//--------------------------------------------------------------------------------------------------
function TQRVCLModelRendererGL.MousePosToGLPoint(hWnd: THandle; out viewRect: TQRRect): TQRVector3D;
var
    p:                                         TPoint;
    clientRect:                                TRect;
    mouseX, mouseY, clientWidth, clientHeight: Single;
begin
    // no window or control?
    if (hWnd = 0) then
    begin
        Result := TQRVector3D.Create(0.0, 0.0, 0.0);
        Exit;
    end;

    // get mouse position
    GetCursorPos(p);

    // convert to window or control client coordinates
    if (not ScreenToClient(hWnd, p)) then
    begin
        Result := TQRVector3D.Create(0.0, 0.0, 0.0);
        Exit;
    end;

    mouseX := p.x;
    mouseY := p.y;

    // get window or control client rect
    GetClientRect(hWnd, clientRect);

    // calculate client width and height
    clientWidth  := (clientRect.right  - clientRect.left);
    clientHeight := (clientRect.bottom - clientRect.top);

    // convert mouse position to OpenGL position
    Result := TQRVector3D.Create(viewRect.Min.X + ((mouseX * viewRect.Width)  / clientWidth),
                                 viewRect.Min.Y - ((mouseY * viewRect.Height) / clientHeight),
                                 0.0);
end;
//--------------------------------------------------------------------------------------------------
procedure TQRVCLModelRendererGL.GetBitmapFromOpenGL(pBitmap: Vcl.Graphics.TBitmap);
var
    dimensions: array [0..3] of GLint;
    pPixels:    PQRRGBQuadArray;
    header:     TBitmapInfo;
    x, y:       GLint;
    offset:     NativeUInt;
begin
    // no bitmap?
    if (not Assigned(pBitmap)) then
        Exit;

    // get viewport dimensions
    glGetIntegerv(GL_VIEWPORT, PGLInt(@dimensions));

    // failed?
    if ((dimensions[2] <= 0) or (dimensions[3] <= 0)) then
        Exit;

    pPixels := nil;

    try
        // create bits to contain bitmap
        GetMem(pPixels, dimensions[2] * dimensions[3] * 4);

        // flush OpenGL
        glFinish();
        glPixelStorei(GL_PACK_ALIGNMENT,   4);
        glPixelStorei(GL_PACK_ROW_LENGTH,  0);
        glPixelStorei(GL_PACK_SKIP_ROWS,   0);
        glPixelStorei(GL_PACK_SKIP_PIXELS, 0);

        // get pixels from last OpenGL rendering
        glReadPixels(0, 0, dimensions[2], dimensions[3], GL_RGBA, GL_UNSIGNED_BYTE, pPixels);

        // configure destination bitmap
        pBitmap.PixelFormat := pf32bit;
        pBitmap.SetSize(dimensions[2], dimensions[3]);

        // configure bitmap header
        header.bmiHeader.biSize        := sizeof(TBitmapInfoHeader);
        header.bmiHeader.biWidth       := dimensions[2];
        header.bmiHeader.biHeight      := dimensions[3];
        header.bmiHeader.biPlanes      := 1;
        header.bmiHeader.biBitCount    := 32;
        header.bmiHeader.biCompression := BI_RGB;
        header.bmiHeader.biSizeImage   := dimensions[2] * dimensions[3] * 4;

        offset := 0;

        // swap red and blue in bitmap
        for x := 0 to dimensions[2] - 1 do
            for y := 0 to dimensions[3] - 1 do
            begin
                // swap red and blue in pixel
                TQRMemoryHelper.Swap<Byte>(pPixels[offset].rgbRed, pPixels[offset].rgbBlue);
                Inc(offset);
            end;

        // copy bitmap content from OpenGL rendered surface to destination
        SetDIBits(pBitmap.Canvas.Handle,
                  pBitmap.Handle,
                  0,
                  dimensions[3],
                  pPixels,
                  &header,
                  DIB_RGB_COLORS);
    finally
        if (Assigned(pPixels)) then
            FreeMem(pPixels);
    end;
end;
//--------------------------------------------------------------------------------------------------
function TQRVCLModelRendererGL.CreateTexture(width, height, format: WORD;
                                                           pPixels: Pointer;
                           minFilter, magFilter, targetID: GLuint): GLInt;
var
    texture: GLuint;
begin
    // create and bind new OpenGL texture
    glGenTextures(1, @texture);
    glBindTexture(targetID, texture);

    // set texture environment parameters
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

    // set texture filtering
    glTexParameteri(targetID, GL_TEXTURE_MIN_FILTER, minFilter);
    glTexParameteri(targetID, GL_TEXTURE_MAG_FILTER, magFilter);

    // set texture wrapping mode
    glTexParameteri(targetID, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(targetID, GL_TEXTURE_WRAP_T, GL_REPEAT);

    // generate texture from bitmap data
    glTexImage2D(targetID, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, pPixels);

    Result := texture;
end;
//--------------------------------------------------------------------------------------------------
procedure TQRVCLModelRendererGL.Draw(var mesh: TQRMesh;
                            const translation: TQRVector3D;
                                    rotationX,
                                    rotationY,
                                    rotationZ: Single;
                                  const scale: TQRVector3D;
                               const textures: TQRTextures);
var
    count, stride, offset, i: NativeUInt;
begin
    // get mesh count
    count := Length(mesh);

    // no mesh to draw?
    if (count = 0) then
        Exit;

    // calculate stride. As all meshes share the same vertex properties, the first mesh can be used
    // to extract vertex format info
    if (mesh[0].m_CoordType = EQR_VC_XYZ) then
        stride := 3
    else
        stride := 2;

    // do use normals array?
    if (EQR_VF_Normals in mesh[0].m_Format) then
        Inc(stride, 3);

    // do use textures coordinates array?
    if (EQR_VF_TexCoords in mesh[0].m_Format) then
        Inc(stride, 2);

    // do use colors array?
    if (EQR_VF_Colors in mesh[0].m_Format) then
        Inc(stride, 4);

    glMatrixMode(GL_MODELVIEW);

    glPushMatrix();

    // place model into 3D world
    glTranslatef(translation.X, translation.Y, translation.Z);
    glRotatef(TQRMathsHelper.RadToDeg(rotationX), 1.0, 0.0, 0.0);
    glRotatef(TQRMathsHelper.RadToDeg(rotationY), 0.0, 1.0, 0.0);
    glRotatef(TQRMathsHelper.RadToDeg(rotationZ), 0.0, 0.0, 1.0);
    glScalef(scale.X, scale.Y, scale.Z);

    // iterate through vertices to draw
    for i := 0 to count - 1 do
    begin
        SelectTexture(textures, mesh[i].m_Name);

        // bind vertex array
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(3,
                        GL_FLOAT,
                        stride * SizeOf(Single),
                        @mesh[i].m_Buffer[0]);

        offset := 3;

        // bind normals array
        if (EQR_VF_Normals in mesh[i].m_Format) then
        begin
            glEnableClientState(GL_NORMAL_ARRAY);
            glNormalPointer(GL_FLOAT,
                            stride * SizeOf(Single),
                            @mesh[i].m_Buffer[offset]);

            Inc(offset, 3);
        end;

        // bind texture coordinates array
        if (EQR_VF_TexCoords in mesh[i].m_Format) then
        begin
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(2,
                              GL_FLOAT,
                              stride * SizeOf(Single),
                              @mesh[i].m_Buffer[offset]);

            Inc(offset, 2);
        end;

        // bind colors array
        if (EQR_VF_Colors in mesh[i].m_Format) then
        begin
            glEnableClientState(GL_COLOR_ARRAY);
            glColorPointer(4,
                           GL_FLOAT,
                           stride * SizeOf(Single),
                           @mesh[i].m_Buffer[offset]);
        end;

        // draw mesh
        case mesh[i].m_Type of
            EQR_VT_Triangles:     glDrawArrays(GL_TRIANGLES,      0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
            EQR_VT_TriangleStrip: glDrawArrays(GL_TRIANGLE_STRIP, 0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
            EQR_VT_TriangleFan:   glDrawArrays(GL_TRIANGLE_FAN,   0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
            EQR_VT_Quads:         glDrawArrays(GL_QUADS,          0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
            EQR_VT_QuadStrip:     glDrawArrays(GL_QUAD_STRIP,     0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
        else
            raise Exception.Create('Unknown vertex type');
        end;

        // unbind vertex array
        glDisableClientState(GL_VERTEX_ARRAY);

        // unbind normals array
        if (EQR_VF_Normals in mesh[i].m_Format) then
            glDisableClientState(GL_NORMAL_ARRAY);

        // unbind texture coordinates array
        if (EQR_VF_TexCoords in mesh[i].m_Format) then
            glDisableClientState(GL_TEXTURE_COORD_ARRAY);

        // unbind colors array
        if (EQR_VF_Colors in mesh[i].m_Format) then
            glDisableClientState(GL_COLOR_ARRAY);

        glFlush();
    end;

    glPopMatrix();
end;
//--------------------------------------------------------------------------------------------------
procedure TQRVCLModelRendererGL.Draw(var mesh: TQRMesh;
                            const modelMatrix: TQRMatrix4x4;
                               const textures: TQRTextures);
var
    count, stride, offset, i: NativeUInt;
begin
    // get mesh count
    count := Length(mesh);

    // no mesh to draw?
    if (count = 0) then
        Exit;

    // calculate stride. As all meshes share the same vertex properties, the first mesh can be used
    // to extract vertex format info
    if (mesh[0].m_CoordType = EQR_VC_XYZ) then
        stride := 3
    else
        stride := 2;

    // do use normals array?
    if (EQR_VF_Normals in mesh[0].m_Format) then
        Inc(stride, 3);

    // do use textures coordinates array?
    if (EQR_VF_TexCoords in mesh[0].m_Format) then
        Inc(stride, 2);

    // do use colors array?
    if (EQR_VF_Colors in mesh[0].m_Format) then
        Inc(stride, 4);

    glMatrixMode(GL_MODELVIEW);

    glPushMatrix();

    // place model into 3D world
    glLoadMatrixf(PGLfloat(modelMatrix.GetPtr()));

    // iterate through vertices to draw
    for i := 0 to count - 1 do
    begin
        SelectTexture(textures, mesh[i].m_Name);

        // bind vertex array
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(3,
                        GL_FLOAT,
                        stride * SizeOf(Single),
                        @mesh[i].m_Buffer[0]);

        offset := 3;

        // bind normals array
        if (EQR_VF_Normals in mesh[i].m_Format) then
        begin
            glEnableClientState(GL_NORMAL_ARRAY);
            glNormalPointer(GL_FLOAT,
                            stride * SizeOf(Single),
                            @mesh[i].m_Buffer[offset]);

            Inc(offset, 3);
        end;

        // bind texture coordinates array
        if (EQR_VF_TexCoords in mesh[i].m_Format) then
        begin
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(2,
                              GL_FLOAT,
                              stride * SizeOf(Single),
                              @mesh[i].m_Buffer[offset]);

            Inc(offset, 2);
        end;

        // bind colors array
        if (EQR_VF_Colors in mesh[i].m_Format) then
        begin
            glEnableClientState(GL_COLOR_ARRAY);
            glColorPointer(4,
                           GL_FLOAT,
                           stride * SizeOf(Single),
                           @mesh[i].m_Buffer[offset]);
        end;

        // draw mesh
        case (mesh[i].m_Type) of
            EQR_VT_Triangles:     glDrawArrays(GL_TRIANGLES,      0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
            EQR_VT_TriangleStrip: glDrawArrays(GL_TRIANGLE_STRIP, 0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
            EQR_VT_TriangleFan:   glDrawArrays(GL_TRIANGLE_FAN,   0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
            EQR_VT_Quads:         glDrawArrays(GL_QUADS,          0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
            EQR_VT_QuadStrip:     glDrawArrays(GL_QUAD_STRIP,     0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
        else
            raise Exception.Create('Unknown vertex type');
        end;

        // unbind vertex array
        glDisableClientState(GL_VERTEX_ARRAY);

        // unbind normals array
        if (EQR_VF_Normals in mesh[i].m_Format) then
            glDisableClientState(GL_NORMAL_ARRAY);

        // unbind texture coordinates array
        if (EQR_VF_TexCoords in mesh[i].m_Format) then
            glDisableClientState(GL_TEXTURE_COORD_ARRAY);

        // unbind colors array
        if (EQR_VF_Colors in mesh[i].m_Format) then
            glDisableClientState(GL_COLOR_ARRAY);

        glFlush();
    end;

    glPopMatrix();
end;
//--------------------------------------------------------------------------------------------------
function TQRVCLModelRendererGL.Draw(var mesh: TQRMesh;
                           const modelMatrix: TQRMatrix4x4;
                              const textures: TQRTextures;
                                     pShader: TQRShader): Boolean;
var
    count, stride, offset, i:                                NativeUInt;
    uniform, posAttrib, normalAttrib, uvAttrib, colorAttrib: GLint;
begin
    // get mesh count
    count := Length(mesh);

    // no mesh to draw?
    if (count = 0) then
    begin
        Result := False;
        Exit;
    end;

    // no shader program?
    if (not Assigned(pShader)) then
    begin
        Result := False;
        Exit;
    end;

    try
        // bind shader program
        pShader.Use(True);

        // get model matrix slot from shader
        uniform := GetUniform(pShader, EQR_SA_ModelMatrix);

        // found it?
        if (uniform = -1) then
        begin
            Result := False;
            Exit;
        end;

        // connect model matrix to shader
        glUniformMatrix4fv(uniform, 1, GL_FALSE, PGLfloat(modelMatrix.GetPtr()));

        // get shader position attribute
        posAttrib := GetAttribute(pShader, EQR_SA_Position);

        // found it?
        if (posAttrib = -1) then
        begin
            Result := False;
            Exit;
        end;

        // calculate stride. As all meshes share the same vertex properties, the first mesh can
        // be used to extract vertex format info
        if (mesh[0].m_CoordType = EQR_VC_XYZ) then
            stride := 3
        else
            stride := 2;

        normalAttrib := -1;

        // do use shader normal attribute?
        if (EQR_VF_Normals in mesh[0].m_Format) then
        begin
            // get shader normal attribute
            normalAttrib := GetAttribute(pShader, EQR_SA_Normal);

            // found it?
            if (normalAttrib = -1) then
            begin
                Result := False;
                Exit;
            end;

            Inc(stride, 3);
        end;

        uvAttrib := -1;

        // do use shader UV attribute?
        if (EQR_VF_TexCoords in mesh[0].m_Format) then
        begin
            // get shader UV attribute
            uvAttrib := GetAttribute(pShader, EQR_SA_Texture);

            // found it?
            if (uvAttrib = -1) then
            begin
                Result := False;
                Exit;
            end;

            // add texture coordinates to stride
            Inc(stride, 2);
        end;

        colorAttrib := -1;

        // do use shader color attribute?
        if (EQR_VF_Colors in mesh[0].m_Format) then
        begin
            // get shader color attribute
            colorAttrib := GetAttribute(pShader, EQR_SA_Color);

            // found it?
            if (colorAttrib = -1) then
            begin
                Result := False;
                Exit;
            end;

            // add color to stride
            Inc(stride, 4);
        end;

        // iterate through OpenGL meshes
        for i := 0 to count - 1 do
        begin
            SelectTexture(pShader, textures, mesh[i].m_Name);

            offset := 0;

            // connect vertices to vertex shader position attribute
            glEnableVertexAttribArray(posAttrib);
            glVertexAttribPointer(posAttrib,
                                  3,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  stride * SizeOf(Single),
                                  @mesh[i].m_Buffer[offset]);

            if (mesh[i].m_CoordType = EQR_VC_XYZ) then
                offset := 3
            else
                offset := 2;

            // vertex buffer contains normals?
            if (normalAttrib <> -1) then
            begin
                // connect the vertices to the vertex shader normal attribute
                glEnableVertexAttribArray(normalAttrib);
                glVertexAttribPointer(normalAttrib,
                                      3,
                                      GL_FLOAT,
                                      GL_FALSE,
                                      stride * SizeOf(Single),
                                      @mesh[i].m_Buffer[offset]);

                Inc(offset, 3);
            end;

            // vertex buffer contains texture coordinates?
            if (uvAttrib <> -1) then
            begin
                // connect the color to the vertex shader vColor attribute and redirect to
                // the fragment shader
                glEnableVertexAttribArray(uvAttrib);
                glVertexAttribPointer(uvAttrib,
                                      2,
                                      GL_FLOAT,
                                      GL_FALSE,
                                      stride * SizeOf(Single),
                                      @mesh[i].m_Buffer[offset]);

                Inc(offset, 2);
            end;

            // vertex buffer contains colors?
            if (colorAttrib <> -1) then
            begin
                // connect the color to the vertex shader vColor attribute and redirect to
                // the fragment shader
                glEnableVertexAttribArray(colorAttrib);
                glVertexAttribPointer(colorAttrib,
                                      4,
                                      GL_FLOAT,
                                      GL_FALSE,
                                      stride * SizeOf(Single),
                                      @mesh[i].m_Buffer[offset]);
            end;

            // draw mesh
            case (mesh[i].m_Type) of
                EQR_VT_Triangles:     glDrawArrays(GL_TRIANGLES,      0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
                EQR_VT_TriangleStrip: glDrawArrays(GL_TRIANGLE_STRIP, 0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
                EQR_VT_TriangleFan:   glDrawArrays(GL_TRIANGLE_FAN,   0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
                EQR_VT_Quads:         glDrawArrays(GL_QUADS,          0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
                EQR_VT_QuadStrip:     glDrawArrays(GL_QUAD_STRIP,     0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
            else
                raise Exception.Create('Unknown vertex type');
            end;
        end;
    finally
        // unbind shader program
        pShader.Use(False);
    end;

    Result := True;
end;
//--------------------------------------------------------------------------------------------------
function TQRVCLModelRendererGL.Draw(var mesh: TQRMesh;
                              const nextMesh: TQRMesh;
                           const modelMatrix: TQRMatrix4x4;
                         interpolationFactor: Single;
                              const textures: TQRTextures;
                                     pShader: TQRShader): Boolean;
var
    count,
    stride,
    offset,
    i:                   NativeUInt;
    uniform,
    interpolationAttrib,
    posAttrib,
    iPosAttrib,
    normalAttrib,
    iNormalAttrib,
    uvAttrib,
    colorAttrib:         GLint;
begin
    // get mesh count
    count := Length(mesh);

    // no mesh to draw?
    if (count = 0) then
    begin
        Result := False;
        Exit;
    end;

    // no shader program?
    if (not Assigned(pShader)) then
    begin
        Result := False;
        Exit;
    end;

    try
        // bind shader program
        pShader.Use(True);

        // get model matrix slot from shader
        uniform := GetUniform(pShader, EQR_SA_ModelMatrix);

        // found it?
        if (uniform = -1) then
        begin
            Result := False;
            Exit;
        end;

        // connect model matrix to shader
        glUniformMatrix4fv(uniform, 1, GL_FALSE, PGLfloat(modelMatrix.GetPtr()));

        // get shader position attribute
        interpolationAttrib := GetUniform(pShader, EQR_SA_Interpolation);

        // found interpolation attribute?
        if (interpolationAttrib = -1) then
        begin
            Result := False;
            Exit;
        end;

        // send interpolation factor to shader program
        glUniform1f(interpolationAttrib, interpolationFactor);

        // get shader position attribute
        posAttrib := GetAttribute(pShader, EQR_SA_Position);

        // found it?
        if (posAttrib = -1) then
        begin
            Result := False;
            Exit;
        end;

        // get shader interpolation position attribute
        iPosAttrib := GetAttribute(pShader, EQR_SA_InterpolationPos);

        // found it?
        if (iPosAttrib = -1) then
        begin
            Result := False;
            Exit;
        end;

        // calculate stride. As all meshes share the same vertex properties, the first mesh can
        // be used to extract vertex format info
        if (mesh[0].m_CoordType = EQR_VC_XYZ) then
            stride := 3
        else
            stride := 2;

        normalAttrib  := -1;
        iNormalAttrib := -1;

        // do use shader normal attribute?
        if (EQR_VF_Normals in mesh[0].m_Format) then
        begin
            // get shader normal attribute
            normalAttrib := GetAttribute(pShader, EQR_SA_Normal);

            // found it?
            if (normalAttrib = -1) then
            begin
                Result := False;
                Exit;
            end;

            // get shader normal attribute
            iNormalAttrib := GetAttribute(pShader, EQR_SA_InterpolationNormal);

            // found it?
            if (iNormalAttrib = -1) then
            begin
                Result := False;
                Exit;
            end;

            Inc(stride, 3);
        end;

        uvAttrib := -1;

        // do use shader UV attribute?
        if (EQR_VF_TexCoords in mesh[0].m_Format) then
        begin
            // get shader UV attribute
            uvAttrib := GetAttribute(pShader, EQR_SA_Texture);

            // found it?
            if (uvAttrib = -1) then
            begin
                Result := False;
                Exit;
            end;

            // add texture coordinates to stride
            Inc(stride, 2);
        end;

        colorAttrib := -1;

        // do use shader color attribute?
        if (EQR_VF_Colors in mesh[0].m_Format) then
        begin
            // get shader color attribute
            colorAttrib := GetAttribute(pShader, EQR_SA_Color);

            // found it?
            if (colorAttrib = -1) then
            begin
                Result := False;
                Exit;
            end;

            // add color to stride
            Inc(stride, 4);
        end;

        // iterate through OpenGL meshes
        for i := 0 to count - 1 do
        begin
            SelectTexture(pShader, textures, mesh[i].m_Name);

            offset := 0;

            // connect vertices to vertex shader position attribute
            glEnableVertexAttribArray(posAttrib);
            glVertexAttribPointer(posAttrib,
                                  3,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  stride * SizeOf(Single),
                                  @mesh[i].m_Buffer[offset]);

            // connect vertices to vertex shader position attribute
            glEnableVertexAttribArray(iPosAttrib);
            glVertexAttribPointer(iPosAttrib,
                                  3,
                                  GL_FLOAT,
                                  GL_FALSE,
                                  stride * SizeOf(Single),
                                  @nextMesh[i].m_Buffer[offset]);

            if (mesh[i].m_CoordType = EQR_VC_XYZ) then
                offset := 3
            else
                offset := 2;

            // vertex buffer contains normals?
            if (normalAttrib <> -1) then
            begin
                // connect the normals to the vertex shader normal attribute
                glEnableVertexAttribArray(normalAttrib);
                glVertexAttribPointer(normalAttrib,
                                      3,
                                      GL_FLOAT,
                                      GL_FALSE,
                                      stride * SizeOf(Single),
                                      @mesh[i].m_Buffer[offset]);

                // vertex buffer contains interpolated normals?
                if (iNormalAttrib <> -1) then
                begin
                    // connect the interpolated normals to the vertex shader normal attribute
                    glEnableVertexAttribArray(iNormalAttrib);
                    glVertexAttribPointer(iNormalAttrib,
                                          3,
                                          GL_FLOAT,
                                          GL_FALSE,
                                          stride * SizeOf(Single),
                                          @nextMesh[i].m_Buffer[offset]);
                end;

                Inc(offset, 3);
            end;

            // vertex buffer contains texture coordinates?
            if (uvAttrib <> -1) then
            begin
                // connect the color to the vertex shader vColor attribute and redirect to
                // the fragment shader
                glEnableVertexAttribArray(uvAttrib);
                glVertexAttribPointer(uvAttrib,
                                      2,
                                      GL_FLOAT,
                                      GL_FALSE,
                                      stride * SizeOf(Single),
                                      @mesh[i].m_Buffer[offset]);

                Inc(offset, 2);
            end;

            // vertex buffer contains colors?
            if (colorAttrib <> -1) then
            begin
                // connect the color to the vertex shader vColor attribute and redirect to
                // the fragment shader
                glEnableVertexAttribArray(colorAttrib);
                glVertexAttribPointer(colorAttrib,
                                      4,
                                      GL_FLOAT,
                                      GL_FALSE,
                                      stride * SizeOf(Single),
                                      @mesh[i].m_Buffer[offset]);
            end;

            // draw mesh
            case (mesh[i].m_Type) of
                EQR_VT_Triangles:     glDrawArrays(GL_TRIANGLES,      0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
                EQR_VT_TriangleStrip: glDrawArrays(GL_TRIANGLE_STRIP, 0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
                EQR_VT_TriangleFan:   glDrawArrays(GL_TRIANGLE_FAN,   0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
                EQR_VT_Quads:         glDrawArrays(GL_QUADS,          0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
                EQR_VT_QuadStrip:     glDrawArrays(GL_QUAD_STRIP,     0, NativeUInt(Length(mesh[i].m_Buffer)) div stride);
            else
                raise Exception.Create('Unknown vertex type');
            end;
        end;
    finally
        // unbind shader program
        pShader.Use(False);
    end;

    Result := True;
end;
//--------------------------------------------------------------------------------------------------

end.