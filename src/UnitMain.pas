unit UnitMain;

{
  OSS Mail Server v1.0.0 - Main Form

  The MIT License (MIT)
  Copyright (c) 2012 Guangzhou Cloudstrust Software Development Co., Ltd
  http://cloudstrust.com/

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Layouts,
  FMX.Objects, FMX.ListBox, FMX.Ani, FMX.Gestures, Vcl.IdAntiFreeze, ALIOSS,
  IdContext, IdSMTPServer, IdPOP3Server, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, IdCmdTCPServer, IdExplicitTLSClientServerBase,
  IdIMAP4Server, IdCommandHandlers, FMX.Memo, IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTPBase, IdSMTPRelay;

type
  TIniData = record
    //OSS settings
    OssHostname: string;
    AccessId: string;
    AccessKey: string;

    //Mail settings
    MailHostname: string;
    MailSMTPLogin: boolean;
    MailBucket: string;

    //Accounts
    Accounts: TStringList;
  end;

  TfrmMain = class(TForm)
    styleMain: TStyleBook;
    loToolbar: TLayout;
    ppToolbar: TPopup;
    ppToolbarAnimation: TFloatAnimation;
    loMain: TLayout;
    loHeader: TLayout;
    laTitle: TLabel;
    sbMain: THorzScrollBox;
    loMenu: TLayout;
    lbMenu: TListBox;
    lbiMenuMail: TMetropolisUIListBoxItem;
    laMenuTitle: TLabel;
    tbMain: TToolBar;
    btnMinimize: TButton;
    btnAbout: TButton;
    btnClose: TButton;
    imgMailOn: TImage;
    imgMailOff: TImage;
    lbiMenuSettings: TMetropolisUIListBoxItem;
    loLogs: TLayout;
    laLogsTitle: TLabel;
    tmrDeferredInit: TTimer;
    tmrDeferredLog: TTimer;
    imgSettingsOff: TImage;
    imgOssOff: TImage;
    lbiMenuAccounts: TMetropolisUIListBoxItem;
    imgAccountsOff: TImage;
    pop3: TIdPOP3Server;
    smtp: TIdSMTPServer;
    mmLogs: TMemo;
    imgOssOn: TImage;
    imgAccountsOn: TImage;
    imgAddAccountOn: TImage;
    imgAddAccountOff: TImage;
    smtpRelay: TIdSMTPRelay;
    procedure btnMinimizeClick(Sender: TObject);

    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure btnCloseClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbiMenuSettingsClick(Sender: TObject);
    procedure lbiMenuMailClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrDeferredInitTimer(Sender: TObject);
    procedure tmrDeferredLogTimer(Sender: TObject);
    procedure pop3Connect(AContext: TIdContext);
    procedure pop3Disconnect(AContext: TIdContext);
    procedure pop3Delete(aCmd: TIdCommand; AMsgNo: Integer);
    procedure pop3List(aCmd: TIdCommand; AMsgNo: Integer);
    procedure pop3Stat(aCmd: TIdCommand; out oCount, oSize: Integer);
    procedure pop3CheckUser(aContext: TIdContext;
      aServerContext: TIdPOP3ServerContext);
    procedure pop3Reset(aCmd: TIdCommand);
    procedure pop3Retrieve(aCmd: TIdCommand; AMsgNo: Integer);
    procedure pop3Quit(aCmd: TIdCommand);
    procedure pop3Top(aCmd: TIdCommand; aMsgNo, aLines: Integer);
    procedure pop3UIDL(aCmd: TIdCommand; AMsgNo: Integer);
    procedure pop3BeforeCommandHandler(ASender: TIdCmdTCPServer;
      var AData: string; AContext: TIdContext);
    procedure smtpMsgReceive(ASender: TIdSMTPServerContext; AMsg: TStream;
      var VAction: TIdDataReply);
    procedure smtpBeforeCommandHandler(ASender: TIdCmdTCPServer;
      var AData: string; AContext: TIdContext);
    procedure smtpConnect(AContext: TIdContext);
    procedure smtpDisconnect(AContext: TIdContext);
    procedure smtpMailFrom(ASender: TIdSMTPServerContext;
      const AAddress: string; AParams: TStrings; var VAction: TIdMailFromReply);
    procedure smtpRcptTo(ASender: TIdSMTPServerContext; const AAddress: string;
      AParams: TStrings; var VAction: TIdRCPToReply; var VForward: string);
    procedure smtpReceived(ASender: TIdSMTPServerContext;
      var AReceived: string);
    procedure smtpUserLogin(ASender: TIdSMTPServerContext; const AUsername,
      APassword: string; var VAuthenticated: Boolean);
    procedure lbiMenuAccountsClick(Sender: TObject);
    procedure laLogsTitleClick(Sender: TObject);
  private
    FGestureOrigin: TPointF;
    FGestureInProgress: Boolean;
    FAntiFreeze: TIdAntiFreeze;
    FCachedLogs: TStringList;

    { Private declarations }
    // Common Utilities
    procedure ShowToolbar(const AShow: Boolean);
    procedure SwitchSubTitle(lb: TMetropolisUIListBoxItem);
    function ClickTest: boolean;
    procedure LoadIniFile;
    procedure ClearLogs;

    // Mail Server
    function StartMail: boolean;
    function StopMail: boolean;

    { Private declarations }
  public
    { Public declarations }
    IniData: TIniData;
    CachedBuckets: TStringList;

    procedure SwitchIcon(lb: TMetropolisUIListBoxItem; const imgName: string);
    procedure SaveIniFile;
    procedure LoadCachedBuckets(pVolumns: PAliOssVolumnInfoList = nil);
    procedure AddLog(log: string);
  end;

function PopString(var src: string): string;
procedure CopyBitmap(dest, src: FMX.Types.TBitmap);

var
  frmMain: TfrmMain;
  down: boolean;
  force_mail_stop: boolean;

implementation

{$R *.fmx}

uses DateUtils, IniFiles, UnitMessage, ALIOSSUTIL, ALIOSSOPT, Windows, IdMessage, IdEmailAddress;

const
  OK = '+OK';

var
  lastClickTime: TDateTime;
  currentUsername: string;
  currentGuid: string;
  currentMails: TAliOssFileInfoList;
  deleteMarkers: array of boolean;

function PopString(var src: string): string;
var
  p: integer;
begin
  p := pos('|', src);
  if p <> 0 then
  begin
    result := copy(src, 1, p-1);
    delete(src, 1, p);
  end
  else
  begin
    result := src;
    src := '';
  end;
end;


procedure CopyBitmap(dest, src: FMX.Types.TBitmap);
begin
  dest.Assign(src);
end;

procedure TfrmMain.laLogsTitleClick(Sender: TObject);
begin
  MessageDlg('test', 'hello, world', 'OK', 'Cancel');
end;

procedure TfrmMain.lbiMenuAccountsClick(Sender: TObject);
var
  Form: TCommonCustomForm;
begin
  Form := Application.GetDeviceForm('Accounts');
  if Assigned(Form) then
    Form.Show;
end;

procedure TfrmMain.lbiMenuMailClick(Sender: TObject);
var
  lb: TMetropolisUIListBoxItem;
begin
  if not ClickTest then exit;

  lb := self.FindComponent('lbiMenuMail') as TMetropolisUIListBoxItem;

  if (lb.TagString = 'imgMailOn') and (self.StopMail) then
  begin
    lb.StyleLookup := 'collectionlistboxitem';
    self.SwitchIcon(lb, 'imgMailOff');
    self.SwitchSubTitle(lb);
  end
  else if (lb.TagString = 'imgMailOff') and (self.StartMail) then
  begin
    lb.StyleLookup := 'checkedpanel';
    self.SwitchIcon(lb, 'imgMailOn');
    self.SwitchSubTitle(lb);
  end;

  //mark current time
  ClickTest;
end;

procedure TfrmMain.lbiMenuSettingsClick(Sender: TObject);
var
  Form: TCommonCustomForm;
begin
  Form := Application.GetDeviceForm('Settings');
  if Assigned(Form) then
    Form.Show;
end;

procedure TfrmMain.LoadCachedBuckets(pVolumns: PAliOssVolumnInfoList);
var
  ossfs: TAliOssFileSystem;
  volumns: TAliOssVolumnInfoList;
  I: Integer;
  success: boolean;
begin
  success := false;

  if (pVolumns <> nil) then
  begin
    success := true;
    volumns := pVolumns^;
  end
  else
  begin
    if (self.IniData.OssHostname <> '')
    or (self.IniData.AccessId <> '')
    or (self.IniData.AccessKey <> '') then
    begin
      try
        ossfs := TAliOssFileSystem.Create(self.IniData.AccessId, self.IniData.AccessKey, self.IniData.OssHostname);

        if ossfs.ListVolumns(volumns) then
          success := true;

        ossfs.Destroy;
      except

      end;
    end;
  end;

  if success then
  begin
    self.CachedBuckets.Clear;
    for I := Low(volumns) to High(volumns) do
    begin
      self.CachedBuckets.Add(volumns[I].name);
    end;

    self.AddLog('已缓存bucket列表');
  end
  else
    self.AddLog('缓存bucket列表失败');

end;

procedure TfrmMain.LoadIniFile;
var
  filename: string;
  ini: TIniFile;
  I: Integer;
  count: integer;
begin
  filename := StringReplace(ParamStr(0), '.exe', '.ini', [rfReplaceAll]);
  if FileExists(filename) then
  begin
    ini := TIniFile.Create(filename);

    //OSS
    self.IniData.OssHostname := ini.ReadString('OSS', 'Hostname', '');
    self.IniData.AccessId := ini.ReadString('OSS', 'AccessId', '');
    self.IniData.AccessKey := ini.ReadString('OSS', 'AccessKey', '');

    //Mail
    self.IniData.MailHostname := ini.ReadString('Mail', 'Hostname', 'localhost');
    self.IniData.MailSMTPLogin := ini.ReadBool('Mail', 'SMTPLogin', true);
    self.IniData.MailBucket := ini.ReadString('Mail', 'Bucket', '');

    //Accounts
    count := ini.ReadInteger('Accounts', 'Count', 0);
    self.IniData.Accounts.Clear;
    for I := 1 to count do
    begin
      self.IniData.Accounts.Add(ini.ReadString('Accounts', 'Account'+IntToStr(i), ''));
    end;

    ini.Free;

    self.AddLog('已载入配置文件');

    LoadCachedBuckets;
  end
  else
  begin
    //default values
    self.IniData.MailHostname := 'localhost';
    self.IniData.MailSMTPLogin := true;

    self.AddLog('未找到配置文件，请首先进行参数设置');
  end;
end;

procedure TfrmMain.pop3BeforeCommandHandler(ASender: TIdCmdTCPServer;
  var AData: string; AContext: TIdContext);
var
  cmd: string;
begin
  if UpperCase(Copy(AData, 1, 4)) = 'PASS' then
    cmd := 'PASS ******'
  else
    cmd := AData;
  self.AddLog('[POP3] 客户端命令：' + cmd);
end;

procedure TfrmMain.pop3CheckUser(aContext: TIdContext;
  aServerContext: TIdPOP3ServerContext);
var
  data, guid, username, password, lockstr: string;
  I: Integer;
  found, locked: boolean;
begin
  found := false;
  locked := false;

  for I := 0 to self.IniData.Accounts.Count - 1 do
  begin
    data := self.IniData.Accounts[I];
    guid := PopString(data);
    username := PopString(data);
    password := PopString(data);
    lockstr := PopString(data);

    if ((username = aServerContext.Username) or (username + '@' + self.IniData.MailHostname = aServerContext.Username)) and
      (password = aServerContext.Password) then
    begin
      found := true;
      locked := lockstr = 'true';
      break;
    end;

  end;

  if not found then
  begin
    self.AddLog('[POP3] 身份验证失败，用户名='+aServerContext.Username);
    raise Exception.Create('Authentication failed');
  end
  else
  begin
    if locked then
    begin
      self.AddLog('[POP3] 身份验证失败，该用户被锁定，用户名='+aServerContext.Username);
      raise Exception.Create('User is locked');
    end
    else
    begin
      self.AddLog('[POP3] 身份验证成功，用户名='+aServerContext.Username);
      currentUsername := username;
      currentGuid := guid;
      SetLength(currentMails, 0);
      SetLength(deleteMarkers, 0);
    end;
  end;
end;

procedure TfrmMain.pop3Connect(AContext: TIdContext);
begin
  self.AddLog('[POP3] 接受客户端连接，IP地址：'+AContext.Binding.PeerIP);
end;

//mark a mail to delete
procedure TfrmMain.pop3Delete(aCmd: TIdCommand; AMsgNo: Integer);
begin
  if (AMsgNo >= 1) and (AMsgNo <= length(currentMails)) then
  begin
    deleteMarkers[AMsgNo - 1] := true;

    aCmd.Reply.SetReply(OK, 'message '+IntTostr(AMsgNo)+' deleted');
    aCmd.SendReply;
    self.AddLog('[POP3][DELE] 标记“'+currentUsername+'”用户的邮件：'+currentMails[AMsgNo-1].name);
  end
  else
  begin
    self.AddLog('[POP3][DELE] 客户端命令编号错误：'+IntToStr(AMsgNo));
    raise Exception.Create('Invalid message number');
  end;
end;

procedure TfrmMain.pop3Disconnect(AContext: TIdContext);
begin
  if not force_mail_stop then
    self.AddLog('[POP3] 客户端断开连接，IP地址：'+AContext.Binding.PeerIP);
end;

//list sing mail or all mails
procedure TfrmMain.pop3List(aCmd: TIdCommand; AMsgNo: Integer);
var
  size: integer;
  ossfs: TAliOssFileSystem;
  I: Integer;
begin
  ossfs := TAliOssFileSystem.Create(self.IniData.AccessId, self.IniData.AccessKey, self.IniData.OssHostname);
  ossfs.ChangeVolumn(self.IniData.MailBucket);

  if AMsgNo = -1 then
  begin
    //list all mails
    size := 0;
    for I := Low(currentMails) to High(currentMails) do
      size := size + currentMails[I].size;

    aCmd.Reply.SetReply(OK, IntToStr(length(currentMails))+' message ('+IntToStr(size)+' octets)');
    aCmd.SendReply;
    for I := Low(currentMails) to High(currentMails) do
      aCmd.Context.Connection.IOHandler.WriteLn(IntToStr(i+1)+' '+IntToStr(currentMails[I].size));
    aCmd.Context.Connection.IOHandler.WriteLn('.');

    self.AddLog('[POP3][LIST] 列出“'+currentUsername+'”用户的'+IntToStr(length(currentMails))+'封邮件');
  end
  else
  begin
    //list single mail
    if (AMsgNo >= 1) and (AMsgNo <= length(currentMails)) then
    begin
      size := currentMails[AMsgNo-1].size;

      aCmd.Reply.SetReply(OK, IntToStr(AMsgNo)+' '+IntToStr(size));
      aCmd.SendReply;
      self.AddLog('[POP3][LIST] 列出“'+currentUsername+'”用户的1封邮件');
    end
    else
    begin
      self.AddLog('[POP3][LIST] 客户端命令编号错误：'+IntToStr(AMsgNo));
      raise Exception.Create('Invalid message number');
    end;
  end;

  ossfs.Free;
end;

//quit, delete all marked mails
procedure TfrmMain.pop3Quit(aCmd: TIdCommand);
var
  ossfs: TAliOssFileSystem;
  I: Integer;
begin
  self.AddLog('[POP3][QUIT] “'+currentUsername+'”用户注销登录');

  ossfs := TAliOssFileSystem.Create(self.IniData.AccessId, self.IniData.AccessKey, self.IniData.OssHostname);
  ossfs.ChangeVolumn(self.IniData.MailBucket);

  for I := Low(deleteMarkers) to High(deleteMarkers) do
  begin
    if deleteMarkers[I] then
    begin
      //delete this mail
      ossfs.RemoveFile(currentGuid+'/'+currentMails[I].name);
      self.AddLog('[POP3][QUIT] 删除“'+currentUsername+'”用户的邮件：'+currentMails[I].name);
    end;
  end;
  aCmd.Reply.SetReply(OK, 'Server signing off (maildrop empty)');
  aCmd.SendReply;
end;

//reset delete markers
procedure TfrmMain.pop3Reset(aCmd: TIdCommand);
var
  I: Integer;
begin
  for I := Low(deleteMarkers) to High(deleteMarkers) do
    deleteMarkers[I] := false;

  aCmd.Reply.SetReply(OK, IntTostr(length(deleteMarkers)) + ' messages available');
  aCmd.SendReply;

  self.AddLog('[POP3][RSET] 撤销删除“'+currentUsername+'”用户的邮件');
end;

//download a mail
procedure TfrmMain.pop3Retrieve(aCmd: TIdCommand; AMsgNo: Integer);
var
  oss: TAliOss;
  obj: string;
  ret: TAliOssReturnType;
  body: string;
  mail: TStringList;
begin
  if (AMsgNo >= 1) and (AMsgNo <= length(currentMails)) then
  begin
    obj := currentGuid + '/' + currentMails[AMsgNo-1].name;

    oss := TAliOss.Create(self.IniData.AccessId, self.IniData.AccessKey, self.IniData.OssHostname);
    ret := oss.GetObject(self.IniData.MailBucket, obj);
    if ret.status = 200 then
    begin
      body := ret.body.DataString;
      aCmd.Reply.SetReply(OK, IntToStr(length(body))+' octets');
      aCmd.SendReply;

      mail := TStringList.Create;
      mail.Text := body;
      aCmd.Context.Connection.WriteRFCStrings(mail);
      mail.Free;

      self.AddLog('[POP3][RETR] 成功获取“'+currentUsername+'”用户的邮件：'+obj);
    end
    else
    begin
      self.AddLog('[POP3][RETR] 无法获取“'+currentUsername+'”用户的邮件：'+obj);
    end;

    oss.Free;
  end
  else
  begin
    self.AddLog('[POP3][RETR] 客户端命令编号错误：'+IntToStr(AMsgNo));
    raise Exception.Create('Invalid message number');
  end;
end;

//get new mail information
procedure TfrmMain.pop3Stat(aCmd: TIdCommand; out oCount, oSize: Integer);
var
  ossfs: TAliOssFileSystem;
  mails: TAliOssFileInfoList;
  I: Integer;
  len: Integer;
  size: integer;
begin
  ossfs := TAliOssFileSystem.Create(self.IniData.AccessId, self.IniData.AccessKey, self.IniData.OssHostname);
  ossfs.ChangeVolumn(self.IniData.MailBucket);

  len := 0;
  size := 0;

  if ossfs.ListDirectory(currentGuid, mails) then
  begin
    SetLength(currentMails, length(mails));
    for I := Low(mails) to High(mails) do
    begin
      if mails[I].isFile then
      begin
        currentMails[len] := mails[I];
        inc(len);
        size := size + mails[I].size;
      end;
    end;
  end;

  SetLength(currentMails, len);
  SetLength(deleteMarkers, len);
  for I := Low(deleteMarkers) to High(deleteMarkers) do
  begin
    deleteMarkers[I] := false;
  end;

  ossfs.Free;

  oCount := len;
  oSize := size;

  self.AddLog('[POP3][STAT] 找到“'+currentUsername+'”用户的'+IntToStr(len)+'封邮件，总大小：'+IntToStr(size)+'字节');
end;

//send headers of the message, a blank line, and the first 10 lines of the mail body
procedure TfrmMain.pop3Top(aCmd: TIdCommand; aMsgNo, aLines: Integer);
begin
  //not used
end;

//send unique id listing for single mail or all mails
procedure TfrmMain.pop3UIDL(aCmd: TIdCommand; AMsgNo: Integer);
var
  data: TStringList;
  I: Integer;
begin
  if AMsgNo = -1 then
  begin
    //list all mails
    aCmd.Reply.SetReply(OK, 'unique-id listing follows');
    aCmd.SendReply;

    data := TStringList.Create;
    for I := Low(currentMails) to High(currentMails) do
      data.Add(IntToStr(i+1)+' '+currentMails[i].name);
    data.Add('.');

    aCmd.Context.Connection.WriteRFCStrings(data);
    data.Free;
    self.AddLog('[POP3][UIDL] 列出“'+currentUsername+'”用户的'+IntToStr(length(currentMails))+'封邮件ID');
  end
  else
  begin
    //list single mail
    if (AMsgNo >= 1) and (AMsgNo <= length(currentMails)) then
    begin
      aCmd.Reply.SetReply(OK, IntToStr(AMsgNo)+' '+currentMails[AMsgNo-1].Name);
      aCmd.SendReply;

      self.AddLog('[POP3][UIDL] 列出“'+currentUsername+'”用户的1封邮件ID');
    end
    else
    begin
      self.AddLog('[POP3][UIDL] 客户端命令编号错误：'+IntToStr(AMsgNo));
      raise Exception.Create('Invalid message number');
    end;
  end;
end;

procedure TfrmMain.AddLog(log: string);
begin
  self.FCachedLogs.Add(TimeToStr(Now)+ ' ' + log);
end;

procedure TfrmMain.btnAboutClick(Sender: TObject);
var
  msg: string;
begin
  msg := '软件版本：1.0.0'#13#10
       + '基础类库：OSS (Open Storage Services) Delphi SDK v1.0.0'#13#10
       + '软件授权：MIT许可证 (The MIT License)'#13#10
       + '软件开发：广州云信软件开发有限公司 http://cloudstrust.com'#13#10
       + '联系方式：menway@gmail.com';

  MessageDlg('关于 '+self.Caption, msg, '确定');
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Application.MainForm.Close;
end;

procedure TfrmMain.btnMinimizeClick(Sender: TObject);
begin
  Application.MainForm.WindowState := TWindowState.wsMinimized;
end;

procedure TfrmMain.ClearLogs;
begin
  self.FCachedLogs.Clear;
end;

function TfrmMain.ClickTest: boolean;
begin
  result := MilliSecondsBetween(Now, lastClickTime) > 100;
  lastClickTime := Now;
end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin
  self.loToolbar.BringToFront;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  self.FAntiFreeze.Free;
  self.FCachedLogs.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  self.IniData.Accounts := TStringList.Create;

  FCachedLogs := TStringList.Create;
  self.tmrDeferredLog.Enabled := true;

  self.ClearLogs;
  self.AddLog('应用程序启动');

  self.SwitchIcon(self.lbiMenuMail, 'imgMailOff');
  CopyBitmap(self.lbiMenuSettings.Icon, self.imgSettingsOff.Bitmap);
  CopyBitmap(self.lbiMenuAccounts.Icon, self.imgAccountsOff.Bitmap);

  lastClickTime := Now;

  self.FAntiFreeze := TIdAntiFreeze.Create(self);
  self.FAntiFreeze.IdleTimeOut := 100;
  self.FAntiFreeze.Active := true;

  CachedBuckets := TStringList.Create;

  self.tmrDeferredInit.Enabled := true;

  force_mail_stop := false;
end;

procedure TfrmMain.FormGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
var
  DX, DY : Single;
begin
  if EventInfo.GestureID = igiPan then
  begin
    if (TInteractiveGestureFlag.gfBegin in EventInfo.Flags)
      and ((Sender = ppToolbar)
        or (EventInfo.Location.Y > (ClientHeight - 70))) then
    begin
      FGestureOrigin := EventInfo.Location;
      FGestureInProgress := True;
    end;

    if FGestureInProgress and (TInteractiveGestureFlag.gfEnd in EventInfo.Flags) then
    begin
      FGestureInProgress := False;
      DX := EventInfo.Location.X - FGestureOrigin.X;
      DY := EventInfo.Location.Y - FGestureOrigin.Y;
      if (Abs(DY) > Abs(DX)) then
        ShowToolbar(DY < 0);
    end;
  end
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkEscape then
    ShowToolbar(not ppToolbar.IsOpen);
end;

procedure TfrmMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button = TMouseButton.mbRight then
    ShowToolbar(True)
  else
    ShowToolbar(False);
end;

procedure TfrmMain.SaveIniFile;
var
  filename: string;
  ini: TIniFile;
  I: integer;
begin
  filename := StringReplace(ParamStr(0), '.exe', '.ini', [rfReplaceAll]);
  ini := TIniFile.Create(filename);

  //OSS
  ini.WriteString('OSS', 'Hostname', self.IniData.OssHostname);
  ini.WriteString('OSS', 'AccessId', self.IniData.AccessId);
  ini.WriteString('OSS', 'AccessKey', self.IniData.AccessKey);

  //Mail
  ini.WriteString('Mail', 'Hostname', self.IniData.MailHostname);
  ini.WriteBool('Mail', 'SMTPLogin', self.IniData.MailSMTPLogin);
  ini.WriteString('Mail', 'Bucket', self.IniData.MailBucket);

  //Accounts
  ini.WriteInteger('Accounts', 'Count', self.IniData.Accounts.Count);
  for I := 1 to self.IniData.Accounts.Count do
  begin
    ini.WriteString('Accounts', 'Account'+IntToStr(i), self.IniData.Accounts[i-1]);
  end;

  ini.Free;

  self.AddLog('已保存配置文件');
end;

procedure TfrmMain.ShowToolbar(const AShow: Boolean);
begin
  ppToolbar.Width := ClientWidth;
  ppToolbar.PlacementRectangle.Rect := TRectF.Create(0, ClientHeight-ppToolbar.Height, ClientWidth-1, ClientHeight-1);
  ppToolbarAnimation.StartValue := ppToolbar.Height;
  ppToolbarAnimation.StopValue := 0;

  ppToolbar.IsOpen := AShow;
end;

procedure TfrmMain.smtpBeforeCommandHandler(ASender: TIdCmdTCPServer;
  var AData: string; AContext: TIdContext);
begin
  self.AddLog('[SMTP] 客户端命令：' + AData);
end;

procedure TfrmMain.smtpConnect(AContext: TIdContext);
begin
  self.AddLog('[SMTP] 接受客户端连接，IP地址：'+AContext.Binding.PeerIP);
end;

procedure TfrmMain.smtpDisconnect(AContext: TIdContext);
begin
  if not force_mail_stop then
    self.AddLog('[SMTP] 客户端断开连接，IP地址：'+AContext.Binding.PeerIP);
end;

//send mail, from field
procedure TfrmMain.smtpMailFrom(ASender: TIdSMTPServerContext;
  const AAddress: string; AParams: TStrings; var VAction: TIdMailFromReply);
begin
// The following actions can be returned to the server:
 { mAccept, mReject }

  if Pos('@', AAddress) > 0 then
  begin
    VAction:= mAccept;
    self.AddLog('[SMTP][MAIL FROM] 来源邮箱正常');
  end
  else
  begin
    VAction := mReject;
    self.AddLog('[SMTP][MAIL FROM] 来源邮箱错误');
  end;
end;

//save mail to oss or relay to other server
procedure TfrmMain.smtpMsgReceive(ASender: TIdSMTPServerContext; AMsg: TStream;
  var VAction: TIdDataReply);
var
  msg: TIdMessage;
  str: TStringStream;
  oss: TAliOss;
  ret: TAliOssReturnType;
  opt: TAliOssOption;
  I: Integer;
  guid, username: string;
  addr: string;
  local: boolean;
  J: Integer;
  data: string;
  found: boolean;
  timestamp: string;
  LRelayRecipients: TIdEMailAddressList;
begin
  try
    //decode mail message
    msg := TIdMessage.Create(self);
    msg.LoadFromStream(AMsg);

    LRelayRecipients := nil;

    for I := 0 to ASender.RCPTList.Count - 1 do
    begin
      addr := ASender.RCPTList[I].Address;
      local := lowercase(self.IniData.MailHostname) = lowercase(ASender.RCPTList[I].Domain);
      if local then
      begin
        //local address
        username := ASender.RCPTList[I].User;
        found := false;
        for J := 0 to self.IniData.Accounts.Count - 1 do
        begin
          data := self.IniData.Accounts[J];
          guid := PopString(data);
          if lowercase(username) = lowercase(PopString(data)) then
          begin
            found := true;

            //save to oss
            oss := TAliOss.Create(self.IniData.AccessId, self.IniData.AccessKey, self.IniData.OssHostname);

            opt := TAliOssOption.Create;
            str := TStringStream.Create;
            str.LoadFromStream(AMsg);
            opt.Values[OSS_CONTENT] := str.DataString;
            str.Free;
            timestamp := FormatDateTime('yyyymmddhhmmsszzz', Now);
            ret := oss.UploadFileByContent(self.IniData.MailBucket, guid+'/'+timestamp+'.eml', opt);
            if ret.status = 200 then
            begin
              self.AddLog('[SMTP][RCPT] 用户“'+currentUsername+'”成功发送内部邮件到：'+addr);
            end
            else
            begin
              self.AddLog('[SMTP][RCPT] 用户“'+currentUsername+'”无法发送内部邮件到：'+addr+'，未知错误');
            end;

            oss.Free;
            opt.Free;
          end;

        end;

        if not found then
        begin
          self.AddLog('[SMTP][RCPT] 用户“'+currentUsername+'”无法发送内部邮件到：'+addr+'，收件人账户不存在');
        end;
      end
      else
      begin
        //remote address

        if not Assigned(LRelayRecipients) then LRelayRecipients := TIdEMailAddressList.Create(nil);
        LRelayRecipients.Add.Assign(ASender.RCPTList[I]);

        self.AddLog('[SMTP][RCPT] 用户“'+currentUsername+'”发送外部邮件到：'+addr);
      end;
    end;

    //relay
    if Assigned(LRelayRecipients) then
    begin
      self.smtpRelay.Send(msg, LRelayRecipients);
    end;

    LRelayRecipients.Free;

    msg.Free;
  except

  end;
end;

procedure TfrmMain.smtpRcptTo(ASender: TIdSMTPServerContext;
  const AAddress: string; AParams: TStrings; var VAction: TIdRCPToReply;
  var VForward: string);
begin
  // The following actions can be returned to the server:
 {
    rAddressOk, //address is okay
    rRelayDenied, //we do not relay for third-parties
    rInvalid, //invalid address
    rWillForward, //not local - we will forward
    rNoForward, //not local - will not forward - please use
    rTooManyAddresses, //too many addresses
    rDisabledPerm, //disabled permanently - not accepting E-Mail
    rDisabledTemp //disabled temporarily - not accepting E-Mail
 }

  if Pos('@', AAddress) > 0 then
  begin
    VAction := rAddressOk;
    self.AddLog('[SMTP][RCPT TO] 目的邮箱正常');
  end
  else
  begin
    VAction :=rInvalid;
    self.AddLog('[SMTP][RCPT TO] 目的邮箱错误');
  end;

  {
  //rWillForward will cause a 251 prompt at user client - ignore it for now
  if Pos('@'+self.IniData.MailHostname, AAddress) = 0 then
  begin
    //remote address
    VAction := rWillForward;
    VForward := AAddress;
  end
  }
end;

//control "Received" header
procedure TfrmMain.smtpReceived(ASender: TIdSMTPServerContext;
  var AReceived: string);
begin
  //not used
  AReceived := '';
end;

procedure TfrmMain.smtpUserLogin(ASender: TIdSMTPServerContext; const AUsername,
  APassword: string; var VAuthenticated: Boolean);
var
  I: Integer;
  data: string;
  guid, username, password, lockstr: string;
begin
  if not self.IniData.MailSMTPLogin then
  begin
    //do not validate user info
    VAuthenticated := true;
    self.AddLog('[SMTP] 跳过身份验证');
    exit;
  end;

  VAuthenticated := false;

  for I := 0 to self.IniData.Accounts.Count - 1 do
  begin
    data := self.IniData.Accounts[I];
    guid := PopString(data);
    username := PopString(data);
    password := PopString(data);
    lockstr := PopString(data);
    if ((username = AUsername) or (username+'@'+self.IniData.MailHostname = AUsername)) and (password = APassword) then
    begin
      if lockstr = 'true' then
      begin
        self.AddLog('[SMTP] 身份验证失败，该用户被锁定，用户名='+AUsername);
        exit;
      end;

      currentUsername := username;
      currentGuid := guid;
      VAuthenticated := true;
      self.AddLog('[SMTP] 身份验证成功，用户名='+AUsername);
      exit;
    end;
  end;

  self.AddLog('[SMTP] 身份验证失败，用户名='+AUsername);
end;

//POP3 implementation: ref http://www.devarticles.com/c/a/Delphi-Kylix/Creating-a-POP3-Server
//POP3 workflow: USER -> PASS -> STAT -> LIST -> UIDL -> RETR x -> QUIT
//SMTP implementation: ref http://www.devarticles.com/c/a/Delphi-Kylix/Creating-an-SMTP-Server/
//SMTP workflow: EHLO -> AUTH LOGIN -> MAIL FROM: xxx -> RCPT TO: xxx -> DATA -> QUIT
function TfrmMain.StartMail: boolean;
var
  success: boolean;
begin
  success := false;

  try
    self.pop3.Active := true;
    self.smtp.Active := true;

    success := true;
  except

  end;

  if success then
    self.AddLog('邮件服务器已启动')
  else
    MessageDlg('错误', '邮件服务器启动失败，请检查具体设置。', '确定');

  result := success;
end;

function TfrmMain.StopMail: boolean;
begin
  result := false;
  try
    force_mail_stop := true;
    self.pop3.Active := false;
    self.smtp.Active := false;
    force_mail_stop := false;

    result := true;
    self.AddLog('邮件服务器已停止');
  except

  end;
end;

procedure TfrmMain.SwitchIcon(lb: TMetropolisUIListBoxItem;
  const imgName: string);
var
  img: TImage;
begin
  if (Assigned(lb)) then
  begin
    lb.TagString := imgName;
    img := self.FindComponent(imgName) as TImage;
    if Assigned(img) then
      lb.Icon.Assign(img.Bitmap);
  end;
end;

procedure TfrmMain.SwitchSubTitle(lb: TMetropolisUIListBoxItem);
const
  switchFrom: array[1..4] of string = ('启动', '停止', 'start', 'stop');
  switchTo:   array[1..4] of string = ('停止', '启动', 'stop', 'start');
var
  I: Integer;
begin
  for I := 1 to 4 do
  begin
    if Pos(switchFrom[I], lb.SubTitle) <> 0 then
    begin
      lb.SubTitle := StringReplace(lb.SubTitle, switchFrom[I], switchTo[I], [rfReplaceAll]);
      exit;
    end;
  end;
end;

procedure TfrmMain.tmrDeferredInitTimer(Sender: TObject);
begin
  self.tmrDeferredInit.Enabled := false;

  self.LoadIniFile;
end;

procedure TfrmMain.tmrDeferredLogTimer(Sender: TObject);
var
  I: Integer;
begin
  self.tmrDeferredLog.Enabled := false;
  try
    if self.FCachedLogs.Count <> 0 then
    begin
      for I := 0 to self.FCachedLogs.Count - 1 do
      begin
        self.mmLogs.Lines.Add(self.FCachedLogs[I]);
      end;

      while (self.mmLogs.VScrollBar.Visible) and (self.mmLogs.Lines.Count > 0) do
        self.mmLogs.Lines.Delete(0);

      self.FCachedLogs.Clear;
    end;
  except

  end;
  self.tmrDeferredLog.Enabled := true;
end;

end.
