object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Mels resources installer'
  ClientHeight = 454
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object laInstalledVersions: TLabel
    AlignWithMargins = True
    Left = 10
    Top = 3
    Width = 608
    Height = 13
    Margins.Left = 10
    Margins.Right = 10
    Align = alTop
    Caption = 'RAD Studio installed versions'
    ExplicitWidth = 139
  end
  object lvRADStudioVersions: TListView
    AlignWithMargins = True
    Left = 10
    Top = 22
    Width = 608
    Height = 99
    Margins.Left = 10
    Margins.Right = 10
    Align = alTop
    Columns = <
      item
        Caption = 'Version'
        Width = 150
      end
      item
        AutoSize = True
        Caption = 'Path'
      end>
    ReadOnly = True
    RowSelect = True
    ShowWorkAreas = True
    SmallImages = ilIcons
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = lvRADStudioVersionsChange
  end
  object paDescription: TPanel
    AlignWithMargins = True
    Left = 15
    Top = 127
    Width = 598
    Height = 324
    Margins.Left = 15
    Margins.Right = 15
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object laDescription: TLabel
      Left = 0
      Top = 0
      Width = 598
      Height = 13
      Align = alTop
      Caption = 'Description'
      ExplicitWidth = 53
    end
    object veRADStudioVariables: TValueListEditor
      Left = 292
      Top = 13
      Width = 306
      Height = 311
      Align = alRight
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
      TabOrder = 0
      ExplicitLeft = 288
      ExplicitTop = 0
      ExplicitHeight = 300
    end
  end
  object ilIcons: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Masked = False
    Left = 592
    Top = 8
  end
end
