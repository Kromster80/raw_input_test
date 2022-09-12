program RawInputTest;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form7};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
