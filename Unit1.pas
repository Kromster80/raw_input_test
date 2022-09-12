unit Unit1;
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, UnitRawInput, StdCtrls, ExtCtrls;


type
  TForm1 = class(TForm)
    meInfo: TMemo;
    meEvents: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    fMyRawInput: TMyRawInput;

    procedure DoMessage(var Msg: TMsg; var Handled: Boolean);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  fMyRawInput := TMyRawInput.Create;

  meInfo.Lines.Add(Format('DeviceCount: %d', [fMyRawInput.DeviceCount]));
  for I := 0 to fMyRawInput.DeviceCount - 1 do
    meInfo.Lines.Add(Format('Device %d type: %s', [I, fMyRawInput.GetDeviceInfo(I)]));

  Application.OnMessage := DoMessage;
end;


procedure TForm1.DoMessage(var Msg: TMsg; var Handled: Boolean);
begin
  if Msg.message = WM_INPUT then
  begin
    fMyRawInput.DoMessage(Msg, Handled);

    meEvents.Lines.Add(Format('WM_INPUT: id-%d flags-%d x-%d y-%d',
      [fMyRawInput.MouseInfo.MouseId, fMyRawInput.MouseInfo.RawMouseData.usFlags, fMyRawInput.MouseInfo.RawMouseData.lLastX, fMyRawInput.MouseInfo.RawMouseData.lLastY]));
  end;
end;


end.
