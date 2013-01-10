program ossmailserver;

uses
  FMX.Forms,
  UnitMain in 'UnitMain.pas' {frmMain},
  UnitAccounts in 'UnitAccounts.pas' {frmAccounts},
  ALIOSS in 'ALIOSS.pas',
  UnitMessage in 'UnitMessage.pas' {frmMessage},
  UnitSettings in 'UnitSettings.pas' {frmSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAccounts, frmAccounts);
  Application.CreateForm(TfrmSettings, frmSettings);
  Application.RegisterFormFamily('Main', [TfrmMain]);
  Application.RegisterFormFamily('Settings', [TfrmSettings]);
  Application.RegisterFormFamily('Accounts', [TfrmAccounts]);
  Application.Run;
end.
