/**************************************************************************************************
 * ==> Main --------------------------------------------------------------------------------------*
 **************************************************************************************************
 * Description : 3D ray picking with AABB tree simplification demo main form                      *
 * Developer   : Jean-Milost Reymond                                                              *
 * Copyright   : 2015 - 2016, this file is part of the Mels library, all right reserved           *
 **************************************************************************************************/

#include <vcl.h>
#pragma hdrstop
#include "Main.h"

// std
#include <sstream>
#include <memory>

// Mels library
#include <UTQRGraphics.hpp>
#include <UTQRGeometry.hpp>
#include <UTQR3D.hpp>

// engine
#include "QR_MathsHelper.h"
#include "QR_OpenGLHelper.h"

#pragma package(smart_init)
#pragma link "UTQRCollision"
#pragma resource "*.dfm"

//--------------------------------------------------------------------------------------------------
// TMainForm
//--------------------------------------------------------------------------------------------------
TMainForm* MainForm;
//--------------------------------------------------------------------------------------------------
__fastcall TMainForm::TMainForm(TComponent* pOwner) :
    TForm(pOwner),
    m_hDC(NULL),
    m_hRC(NULL),
    m_pAABBTree(NULL),
    m_PreviousTime(0),
    m_CollidePolygonsCount(0),
    m_HighestHit(0),
    m_Theta(0.0f),
    m_Rotate(false)
{
    std::auto_ptr<TQRColor> pColor(new TQRColor(0, 0, 255, 255));

    // create a demo blue sphere
    std::auto_ptr<TQRSphereModel> pSphereModel(new TQRSphereModel());
    pSphereModel->Slices       = 20;
    pSphereModel->Stacks       = 20;
    pSphereModel->Radius       = 1.0f;
    pSphereModel->Color        = pColor.get();
    pSphereModel->VertexFormat = TQRVertexFormat() << EQR_VF_Colors;

    // create aligned-axis bounding box tree
    m_pAABBTree = new TQRAABBTree();

    pSphereModel->GetMesh(m_Mesh, m_pAABBTree);
}
//--------------------------------------------------------------------------------------------------
__fastcall TMainForm::~TMainForm()
{
    // delete aabb tree
    if (m_pAABBTree)
        delete m_pAABBTree;

    // shutdown OpenGL
    QR_OpenGLHelper::DisableOpenGL(Handle, m_hDC, m_hRC);
}
//--------------------------------------------------------------------------------------------------
void __fastcall TMainForm::FormShow(TObject* pSender)
{
    // was OpenGL already initialized?
    if (m_hRC)
        return;

    // initialize OpenGL
    if (!QR_OpenGLHelper::EnableOpenGL(Handle, m_hDC, m_hRC))
    {
        MessageDlg("OpenGL could not be initialized.\r\n\r\nApplication will close.", mtError,
                TMsgDlgButtons() << mbOK, 0);;
        Application->Terminate();
        return;
    }

    // configure OpenGL
    ConfigOpenGL();
    QR_OpenGLHelper::CreateViewport(ClientWidth, ClientHeight, false);

    // from now, OpenGL will draw scene every time the thread do nothing else
    Application->OnIdle = OnIdle;
}
//--------------------------------------------------------------------------------------------------
void __fastcall TMainForm::FormPaint(TObject *Sender)
{
    RenderGLScene();
}
//--------------------------------------------------------------------------------------------------
void __fastcall TMainForm::acRotateExecute(TObject* pSender)
{
    acRotate->Checked = !acRotate->Checked;
    m_Rotate          =  acRotate->Checked;
    btRotate->Caption =  m_Rotate ? L"Stop" : L"Rotate";
}
//--------------------------------------------------------------------------------------------------
void __fastcall TMainForm::RenderGLScene()
{
    // calculate time interval
    const std::time_t now            = ::GetTickCount();
    const double      elapsedTime    = (now - m_PreviousTime);
                      m_PreviousTime =  now;

    // clear scene
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // draw scene
    DrawScene(elapsedTime);

    glFlush();

    // finalize scene
    ::SwapBuffers(m_hDC);
}
//--------------------------------------------------------------------------------------------------
void __fastcall TMainForm::DrawScene(const double& elapsedTime)
{
    // do rotate sphere?
    if (m_Rotate)
    {
        // calculate full max angle (i.e. 360�)
        const float fullAngle = M_PI * 2.0f;

        // calculate next rotation angle
        m_Theta = (m_Theta + 0.008f > fullAngle) ? ((m_Theta + 0.008f) - fullAngle) : m_Theta + 0.008f;
    }

    TQRTextures textures;

    // draw mesh
    QR_OpenGLHelper::Draw(m_Mesh,
                          TQRVector3D(0.0f, 0.0f, 0.0f),
                          0.0f,
                          m_Theta,
                          0.0f,
                          TQRVector3D(1.0f, 1.0f, 1.0f),
                          textures);

    TQRRect rect(-1.0f, 1.0f, 2.0f, 2.0f);

    // convert mouse position to OpenGL point, that will be used as ray start pos, and create ray dir
    TQRVector3D rayPos = QR_OpenGLHelper::MousePosToGLPoint(Handle, rect);
    TQRVector3D rayDir(0.0f, 0.0f, 1.0f);

    // prepare rotation matrix
    TQRMatrix4x4 rotateMatrix = TQRMatrix4x4::Identity();
    rotateMatrix.Rotate(-m_Theta, TQRVector3D(0.0f, 1.0f, 0.0f));

    // rotate ray position and direction
    rayPos = rotateMatrix.Transform(rayPos);
    rayDir = rotateMatrix.Transform(rayDir);

    // create and populate ray from mouse position
    std::auto_ptr<TQRRay> pRay(new TQRRay());
    pRay->Pos = &rayPos;
    pRay->Dir = &rayDir;

    TQRPolygons polygons;

    // get polygons to check for collision by resolving AABB tree
    m_pAABBTree->Resolve(pRay.get(), polygons);

    const std::size_t polygonCount = polygons.Length;
          TQRPolygons polygonToDraw;

    // update highest hit
    m_HighestHit = std::max(m_HighestHit, polygonCount);

    // iterate through polygons to check
    for (std::size_t i = 0; i < polygonCount; ++i)
        // is polygon intersecting ray?
        if (TQRCollisionHelper::GetRayPolygonCollision(pRay.get(), polygons[i]))
        {
            // ad polygon in collision to resulting list
            polygonToDraw.Length                   += 1;
            polygonToDraw[polygonToDraw.Length - 1] = polygons[i];
        }

    const std::size_t polygonToDrawCount = polygonToDraw.Length;

    glPushMatrix();

    // place triangles into 3D world
    glTranslatef(0.0f, 0.0f, 0.0f);
    glRotatef(0.0f, 1.0, 0.0, 0.0);
    glRotatef(QR_MathsHelper::RadToDeg(m_Theta), 0.0, 1.0, 0.0);
    glRotatef(0.0f, 0.0, 0.0, 1.0);
    glScalef(1.0f, 1.0f, 1.0f);

    // found collide polygons to draw?
    for (unsigned i = 0; i < polygonToDrawCount; ++i)
    {
        glBegin(GL_TRIANGLES);

        // draw vertex 1
        glColor3f(1.0f, 0.0f, 0.0f);
        glVertex3f(polygonToDraw[i].Vertex1->X,
                   polygonToDraw[i].Vertex1->Y,
                   polygonToDraw[i].Vertex1->Z);

        // draw vertex 2
        glColor3f(0.8f, 0.0f, 0.2f);
        glVertex3f(polygonToDraw[i].Vertex2->X,
                   polygonToDraw[i].Vertex2->Y,
                   polygonToDraw[i].Vertex2->Z);

        // draw vertex 3
        glColor3f(1.0f, 0.12f, 0.2f);
        glVertex3f(polygonToDraw[i].Vertex3->X,
                   polygonToDraw[i].Vertex3->Y,
                   polygonToDraw[i].Vertex3->Z);

        glEnd();

        glFlush();
    }

    glPopMatrix();

    // show collision detection status
    ShowStatus(polygonCount, polygonToDrawCount);
}
//--------------------------------------------------------------------------------------------------
void __fastcall TMainForm::OnIdle(TObject* pSender, bool& done)
{
    done = false;

    // draw OpenGL scene every time application do nothing
    RenderGLScene();
}
//--------------------------------------------------------------------------------------------------
void TMainForm::ShowStatus(int toTest, int inCollision) const
{
    // show collision detection status
    laTotal->Caption       = L"Total: "        + ::IntToStr((int)m_CollidePolygonsCount);
    laToTest->Caption      = L"To test: "      + ::IntToStr(toTest);
    laInCollision->Caption = L"In collision: " + ::IntToStr(inCollision);
    laHighestHit->Caption  = L"Highest hit: "  + ::IntToStr((int)m_HighestHit);
}
//--------------------------------------------------------------------------------------------------
void TMainForm::ConfigOpenGL()
{
    // configure OpenGL depth testing
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
    glDepthFunc(GL_LEQUAL);
    glDepthRange(0.0f, 1.0f);

    // enable culling
    glDisable(GL_CULL_FACE);
    glCullFace(GL_NONE);
}
//--------------------------------------------------------------------------------------------------
void TMainForm::CreateSphere(float       radius,
                             int         slices,
                             int         stacks,
                             std::size_t color,
                             TQRVertex&  vertex,
                             TQRMesh&    mesh)
{
    int   i;
    int   j;
    int   meshIndex;
    int   fanLength;
    int   index;
    float majorStep;
    float minorStep;
    float a;
    float b;
    float r0;
    float r1;
    float z0;
    float z1;
    float c;
    float x;
    float y;

    // configure vertex format
    vertex.m_CoordType = EQR_VC_XYZ;
    vertex.m_Type      = EQR_VT_TriangleStrip;
    vertex.m_Stride    = vertex.CalculateStride();

    const float       pi     = atan(1.0f) * 4.0f;
    const std::size_t stride = vertex.m_Stride;

    // initialize basic values
    majorStep = (pi          / slices);
    minorStep = ((2.0f * pi) / stacks);

    // iterate through vertex slices
    for (i = 0; i <= slices; ++i)
    {
        // calculate values for next slice
        a  = i * majorStep;
        b  = a + majorStep;
        r0 = radius * std::sinf(a);
        r1 = radius * std::sinf(b);
        z0 = radius * std::cosf(a);
        z1 = radius * std::cosf(b);

        // calculate current index and slice fan length
        meshIndex = mesh.Length;
        fanLength = (stacks + 1) * stride * 2;

        // adde new mesh in output array
        mesh.Length += 1;

        // populate mesh
        mesh[meshIndex]                 = vertex.Clone();
        mesh[meshIndex].m_Buffer.Length = fanLength;

        index = 0;

        // iterate through vertex stacks
        for (j = 0; j <= stacks; ++j)
        {
            c = j * minorStep;
            x = std::cosf(c);
            y = std::sinf(c);

            // set vertex data
            mesh[meshIndex].m_Buffer[index]     = x * r0;
            mesh[meshIndex].m_Buffer[index + 1] = y * r0;
            mesh[meshIndex].m_Buffer[index + 2] = z0;

            index += 3;

            // do generate normals?
            if (vertex.m_Format.Contains(EQR_VF_Normals))
            {
                // set normals
                mesh[meshIndex].m_Buffer[index]     = (x * r0) / radius;
                mesh[meshIndex].m_Buffer[index + 1] = (y * r0) / radius;
                mesh[meshIndex].m_Buffer[index + 2] = z0       / radius;

                index += 3;
            }

            // do generate texture coordinates?
            if (vertex.m_Format.Contains(EQR_VF_TexCoords))
            {
                // add texture coordinates data to buffer
                mesh[meshIndex].m_Buffer[index]     = ((float)j / (float)stacks);
                mesh[meshIndex].m_Buffer[index + 1] = ((float)i / (float)slices);

                index += 2;
            }

            // do generate colors?
            if (vertex.m_Format.Contains(EQR_VF_Colors))
            {
                // set color data
                mesh[meshIndex].m_Buffer[index]     = (float)((color >> 24) & 0xFF) / 255.0f;
                mesh[meshIndex].m_Buffer[index + 1] = (float)((color >> 16) & 0xFF) / 255.0f;
                mesh[meshIndex].m_Buffer[index + 2] = (float)((color >> 8)  & 0xFF) / 255.0f;
                mesh[meshIndex].m_Buffer[index + 3] = (float) (color        & 0xFF) / 255.0f;

                index += 4;
            }

            mesh[meshIndex].m_Buffer[index]     = x * r1;
            mesh[meshIndex].m_Buffer[index + 1] = y * r1;
            mesh[meshIndex].m_Buffer[index + 2] = z1;

            index += 3;

            // do generate normals?
            if (vertex.m_Format.Contains(EQR_VF_Normals))
            {
                // set normals
                mesh[meshIndex].m_Buffer[index]     = (x * r1) / radius;
                mesh[meshIndex].m_Buffer[index + 1] = (y * r1) / radius;
                mesh[meshIndex].m_Buffer[index + 2] =  z1      / radius;

                index += 3;
            }

            // do generate texture coordinates?
            if (vertex.m_Format.Contains(EQR_VF_TexCoords))
            {
                // add texture coordinates data to buffer
                mesh[meshIndex].m_Buffer[index]     = ( (float)j         / (float)stacks);
                mesh[meshIndex].m_Buffer[index + 1] = (((float)i + 1.0f) / (float)slices);

                index += 2;
            }

            // do generate colors?
            if (vertex.m_Format.Contains(EQR_VF_Colors))
            {
                // set color data
                mesh[meshIndex].m_Buffer[index]     = (float)((color >> 24) & 0xFF) / 255.0f;
                mesh[meshIndex].m_Buffer[index + 1] = (float)((color >> 16) & 0xFF) / 255.0f;
                mesh[meshIndex].m_Buffer[index + 2] = (float)((color >> 8)  & 0xFF) / 255.0f;
                mesh[meshIndex].m_Buffer[index + 3] = (float) (color        & 0xFF) / 255.0f;

                index += 4;
            }
        }
    }
}
//--------------------------------------------------------------------------------------------------