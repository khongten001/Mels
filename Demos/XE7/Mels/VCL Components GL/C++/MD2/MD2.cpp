/**************************************************************************************************
 * ==> MD2 ---------------------------------------------------------------------------------------*
 **************************************************************************************************
 * Description : MD2 demo main entry point                                                        *
 * Developer   : Jean-Milost Reymond                                                              *
 * Copyright   : 2015 - 2016, this file is part of the Mels library, all right reserved           *
 **************************************************************************************************/

#include <vcl.h>
#pragma hdrstop
#pragma package(smart_init) // madExcept
#pragma link "madExcept"
#pragma link "madLinkDisAsm"
#pragma link "madListHardware"
#pragma link "madListProcesses"
#pragma link "madListModules"
#include <tchar.h>

//--------------------------------------------------------------------------------------------------
USEFORM("Main.cpp", MainForm);
//--------------------------------------------------------------------------------------------------
int WINAPI _tWinMain(HINSTANCE, HINSTANCE, LPTSTR, int)
{
    try
    {
         Application->Initialize();
         Application->MainFormOnTaskBar = true;
         Application->CreateForm(__classid(TMainForm), &MainForm);
         Application->Run();
    }
    catch (Exception &exception)
    {
         Application->ShowException(&exception);
    }
    catch (...)
    {
         try
         {
             throw Exception("");
         }
         catch (Exception &exception)
         {
             Application->ShowException(&exception);
         }
    }
    return 0;
}
//--------------------------------------------------------------------------------------------------