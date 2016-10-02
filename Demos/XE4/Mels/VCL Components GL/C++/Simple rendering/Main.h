/**************************************************************************************************
 * ==> Main --------------------------------------------------------------------------------------*
 **************************************************************************************************
 * Description : Simple renderer using Mels components demo main form                             *
 * Developer   : Jean-Milost Reymond                                                              *
 * Copyright   : 2015 - 2016, this file is part of the Mels library, all right reserved           *
 **************************************************************************************************/

#ifndef MainH
#define MainH

// vcl
#include <System.Classes.hpp>
#include <Vcl.Controls.hpp>
#include <Vcl.StdCtrls.hpp>
#include <Vcl.Forms.hpp>
#include <Vcl.ComCtrls.hpp>
#include <Vcl.ExtCtrls.hpp>
#include <UTQRVCLModelComponentGL.hpp>
#include <UTQRVCLSimpleRendererComponentGL.hpp>
#include <Vcl.Dialogs.hpp>

// std
#include <string>

/**
* MD2 demo main form
*@author Jean-Milost Reymond
*/
class TMainForm : public TForm
{
    __published:
        TPanel *paBlueScene;
        TQRVCLSimpleRendererGL *srBlueSurface;
        TPanel *paYellowScene;
        TQRVCLSimpleRendererGL *srYellowSurface;
        TSplitter *spBottom;
        TSplitter *spTop;
        TSplitter *spScenes;
        TPanel *paTopControls;
        TPanel *paBottomControls;
        TLabel *laTopBelowText;
        TEdit *edTopBelowText;
        TLabel *laTopAboveText;
        TEdit *edTopAboveText;
        TCheckBox *ckTopEnableTransparency;
        TCheckBox *ckTopShowBelowText;
        TCheckBox *ckTopShowAboveText;
        TLabel *laTopChangeGlobalTransparency;
        TTrackBar *tbTopGlobalTransparency;
        TPanel *paTopChangeColor;
        TLabel *laTopChangeColor;
        TPanel *paTopChangeColorSelect;
        TColorDialog *cdColors;
        TPanel *paTopChangeColorAlpha;
        TLabel *laTopChangeColorAlpha;
        TTrackBar *tbTopChangeColorAlpha;
        TLabel *laBottomBelowText;
        TLabel *laBottomAboveText;
        TLabel *laBottomChangeGlobalTransparency;
        TEdit *edBottomBelowText;
        TEdit *edBottomAboveText;
        TCheckBox *ckBottomEnableTransparency;
        TCheckBox *ckBottomShowBelowText;
        TCheckBox *ckBottomShowAboveText;
        TTrackBar *tbBottomGlobalTransparency;
        TPanel *paBottomChangeColor;
        TLabel *laBottomChangeColor;
        TPanel *paBottomChangeColorSelect;
        TPanel *paBottomChangeColorAlpha;
        TLabel *laBottomChangeColorAlpha;
        TTrackBar *tbBottomChangeColorAlpha;

        void __fastcall OnTopTextChange(TObject* pSender);
        void __fastcall ckTopEnableTransparencyClick(TObject* pSender);
        void __fastcall ckTopShowBelowTextClick(TObject* pSender);
        void __fastcall ckTopShowAboveTextClick(TObject* pSender);
        void __fastcall tbTopGlobalTransparencyChange(TObject* pSender);
        void __fastcall tbTopChangeColorAlphaChange(TObject* pSender);
        void __fastcall paTopChangeColorSelectClick(TObject* pSender);
        void __fastcall OnBottomTextChange(TObject* pSender);
        void __fastcall ckBottomShowBelowTextClick(TObject* pSender);
        void __fastcall ckBottomShowAboveTextClick(TObject* pSender);
        void __fastcall ckBottomEnableTransparencyClick(TObject* pSender);
        void __fastcall tbBottomGlobalTransparencyChange(TObject* pSender);
        void __fastcall tbBottomChangeColorAlphaChange(TObject* pSender);
        void __fastcall paBottomChangeColorSelectClick(TObject* pSender);
        void __fastcall srBlueSurfaceInitializeScene(TObject* pSender, NativeUInt hDC);
        void __fastcall srYellowSurfaceInitializeScene(TObject* pSender, NativeUInt hDC);
        void __fastcall srBlueSurfaceDrawScene(TObject* pSender, NativeUInt hDC, NativeUInt hGLRC,
                TQRVCLModelRendererGL* pRenderer, TQRVCLModelShaderGL* pShader);
        void __fastcall srYellowSurfaceDrawScene(TObject* pSender, NativeUInt hDC, NativeUInt hGLRC,
                TQRVCLModelRendererGL* pRenderer, TQRVCLModelShaderGL* pShader);
        void __fastcall srBlueSurfaceFinalizeScene(TObject* pSender, NativeUInt hDC);
        void __fastcall srYellowSurfaceFinalizeScene(TObject* pSender, NativeUInt hDC);

    public:
        /**
        * Constructor
        *@param pOwner - form owner
        */
        __fastcall TMainForm(TComponent* pOwner);

        /**
        * Destructor
        */
        virtual __fastcall ~TMainForm();

    private:
        HBRUSH m_hBlackBrush;

        /**
        * Draws the scene background
        *@param hDC - device context to draw on
        *@param pRenderer - surface renderer control
        */
        void DrawBg(HDC hDC, TQRVCLSimpleRendererGL* pRenderer) const;

        /**
        * Draws a triangle covering the entire scene area using OpenGL
        */
        void DrawTriangle() const;

        /**
        * Draws text on a device context
        *@param hDC - device context to draw on
        *@param text - text to draw
        *@param[in, out] rect - rectangle bounding text to draw
        */
        void DrawText(HDC hDC, const std::wstring& text, TRect& rect) const;
};
extern PACKAGE TMainForm* MainForm;
#endif
