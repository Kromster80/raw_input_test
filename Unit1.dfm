object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'RawInputTest'
  ClientHeight = 561
  ClientWidth = 753
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    753
    561)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 20
    Height = 13
    Caption = 'Info'
  end
  object Label2: TLabel
    Left = 8
    Top = 256
    Width = 43
    Height = 13
    Caption = 'Input log'
  end
  object meInfo: TMemo
    Left = 8
    Top = 24
    Width = 737
    Height = 225
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object meEvents: TMemo
    Left = 8
    Top = 272
    Width = 737
    Height = 281
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
end
