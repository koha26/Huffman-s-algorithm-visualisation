program Project1_main;

uses
  Vcl.Forms,
  UnitMain in 'UnitMain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.HelpFile := 'Help\MainHelp.chm';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
