unit UnitSettings;

{
  OSS Mail Server v1.0.0 - Settings Form

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
  FMX.Objects, FMX.ListBox,
  FMX.Gestures, FMX.TabControl, FMX.Ani, FMX.Edit, FMX.Menus;

type
  TfrmSettings = class(TForm)
    styleSettings: TStyleBook;
    loToolbar: TLayout;
    ppToolbar: TPopup;
    ppToolbarAnimation: TFloatAnimation;
    loSettings: TLayout;
    loMenu: TLayout;
    lbSettings: TListBox;
    lbiOssSettings: TMetropolisUIListBoxItem;
    lbiMailSettings: TMetropolisUIListBoxItem;
    loMenuHeader: TLayout;
    laMenuTitle: TLabel;
    loBack: TLayout;
    btnBack: TButton;
    loParameters: TLayout;
    tbSettings: TToolBar;
    ToolbarApplyButton: TButton;
    ToolbarCloseButton: TButton;
    ToolbarAddButton: TButton;
    tcSettings: TTabControl;
    tiOss: TTabItem;
    tiMail: TTabItem;
    sbOss: TVertScrollBox;
    loOssHeader: TLayout;
    imgOssIcon: TImageControl;
    loOssTitles: TLayout;
    laOssTitle: TLabel;
    laOssSubTitle: TLabel;
    sbMail: TVertScrollBox;
    loMailHeader: TLayout;
    imgMailIcon: TImageControl;
    loMailTitles: TLayout;
    laMailTitle: TLabel;
    laMailSubTitle: TLabel;
    laOssHostname: TLabel;
    laOssAccessId: TLabel;
    edOssAccessId: TEdit;
    laOssAccessKey: TLabel;
    edOssAccessKey: TEdit;
    ClearEditButton1: TClearEditButton;
    ClearEditButton2: TClearEditButton;
    pnOssValidate: TPanel;
    btnOssValidate: TButton;
    laMailHostname: TLabel;
    edMailHostname: TEdit;
    ClearEditButton3: TClearEditButton;
    laMailBucket: TLabel;
    laSMTPLogin: TLabel;
    pnSMTPLogin: TPanel;
    rbSMTPLoginOn: TRadioButton;
    rbSMTPLoginOff: TRadioButton;
    pnMailSave: TPanel;
    btnMailSave: TButton;
    cbOssHost: TComboBox;
    pnOssValidateInfo: TPanel;
    pnValidateError: TCalloutPanel;
    lbValidateError: TLabel;
    pnValidateProgress: TPanel;
    aniValidateProgress: TAniIndicator;
    lbValidateProgress: TLabel;
    sbSettings: THorzScrollBox;
    pnMailSaveSuccess: TCalloutPanel;
    lbMailSaveSuccess: TLabel;
    pnValidateSuccess: TCalloutPanel;
    laValidateSuccess: TLabel;
    cbMailBucket: TComboEdit;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    procedure btnBackClick(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure ToolbarCloseButtonClick(Sender: TObject);
    procedure lbiOssSettingsClick(Sender: TObject);
    procedure btnOssValidateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnMailSaveClick(Sender: TObject);
  private
    FGestureOrigin: TPointF;
    FGestureInProgress: Boolean;
    { Private declarations }
    procedure ShowToolbar(AShow: Boolean);

    procedure ReadOss;
    procedure WriteOss;

    procedure ReadMail;
    function ValidateMail: boolean;
    procedure WriteMail;

    procedure SyncBucketList;

    procedure FlashAndDismiss(pn: TCalloutPanel);
  public
    { Public declarations }
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.fmx}

uses ALIOSS, UnitMain, Winapi.ShellAPI, Winapi.Windows, UnitMessage;

procedure SelectItem(cb: TComboEdit; item: string); overload;
var
  idx: integer;
begin
  if item = '' then
    exit;

  idx := cb.Items.IndexOf(item);
  if idx = -1 then
  begin
    //item not found, set text
    cb.Text := item;
  end
  else
    cb.ItemIndex := idx;
end;

procedure SelectItem(cb: TComboBox; item: string); overload;
var
  idx: integer;
begin
  if item = '' then
    exit;

  idx := cb.Items.IndexOf(item);
  if idx = -1 then
  begin
    //item not found, append and select it
    cb.Items.Add(item);
    cb.ItemIndex := cb.Items.Count - 1;
  end
  else
    cb.ItemIndex := idx;
end;

procedure TfrmSettings.btnBackClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSettings.lbiOssSettingsClick(Sender: TObject);
var
  lb: TMetropolisUIListBoxItem;
begin
  self.tcSettings.TabIndex := TFmxObject(Sender).Tag;

  frmMain.SwitchIcon(lbiOssSettings, 'imgOssOff');
  frmMain.SwitchIcon(lbiMailSettings, 'imgMailOff');

  lb := Sender as TMetropolisUIListBoxItem;

  if lb = self.lbiOssSettings then
    frmMain.SwitchIcon(lb, 'imgOssOn')
  else if lb = self.lbiMailSettings then
    frmMain.SwitchIcon(lb, 'imgMailOn');

end;

procedure TfrmSettings.ReadMail;
begin
  try
    self.edMailHostname.Text := frmMain.IniData.MailHostname;
    self.rbSMTPLoginOn.IsChecked := frmMain.IniData.MailSMTPLogin;
    self.rbSMTPLoginOff.IsChecked := not frmMain.IniData.MailSMTPLogin;

    SelectItem(self.cbMailBucket, frmMain.IniData.MailBucket);
  except

  end;
end;

procedure TfrmSettings.ReadOss;
begin
  try
    SelectItem(self.cbOssHost, frmMain.IniData.OssHostname);
    self.edOssAccessId.Text := frmMain.IniData.AccessId;
    self.edOssAccessKey.Text := frmMain.IniData.AccessKey;
  except

  end;
end;

procedure TfrmSettings.btnMailSaveClick(Sender: TObject);
var
  ossfs: TAliOssFileSystem;
begin
  if not self.ValidateMail then
  begin
    MessageDlg('提示', '保存邮件服务器配置失败，请检查配置。', '确定');
    exit;
  end;

  if frmMain.CachedBuckets.IndexOf(self.cbMailBucket.Text) = -1 then
  begin
    if MessageDlg('提示', '指定的bucket“'+self.cbMailBucket.Text+'”不在列表中，是否在服务器创建？', '是', '否') = ID_YES then
    begin
      ossfs := TAliOssFileSystem.Create(frmMain.IniData.AccessId, frmMain.IniData.AccessKey, frmMain.IniData.OssHostname);
      if ossfs.CreateVolumn(self.cbMailBucket.Text) then
        MessageDlg('提示', '成功创建bucket“'+self.cbMailBucket.Text+'”。', '确定')
      else
        MessageDlg('提示', '创建bucket“'+self.cbMailBucket.Text+'”失败，请换个名字重试。', '确定')
    end;
  end;
  
  self.WriteMail;
  frmMain.SaveIniFile;
  frmMain.LoadCachedBuckets;
  self.SyncBucketList;

  FlashAndDismiss(self.pnMailSaveSuccess);

  if frmMain.pop3.Active or frmMain.smtp.Active  then
  begin
    MessageDlg('提示', '检测到邮件服务器正在运行中，新的配置将在重新启动邮件服务器后生效。', '确定');
  end;
end;

procedure TfrmSettings.btnOssValidateClick(Sender: TObject);
var
  ossfs: TAliOssFileSystem;
  success: boolean;
  volumns: TAliOssVolumnInfoList;
begin
  self.pnValidateSuccess.Opacity := 0.0;
  self.pnValidateError.Opacity := 0.0;
  self.pnValidateProgress.Opacity := 1.0;

  success := true;
  try
    ossfs := TAliOssFileSystem.Create(self.edOssAccessId.Text, self.edOssAccessKey.Text, self.cbOssHost.Selected.Text);

    if not ossfs.ListVolumns(volumns) then
      success := false;

    ossfs.Destroy;
  except
    success := false;
  end;

  self.pnValidateProgress.Opacity := 0.0;

  if not success then
  begin
    FlashAndDismiss(self.pnValidateError);
  end
  else
  begin
    FlashAndDismiss(self.pnValidateSuccess);

    self.WriteOss;
    frmMain.SaveIniFile;
    frmMain.LoadCachedBuckets(@volumns);
    self.SyncBucketList;
  end;
end;

procedure TfrmSettings.FlashAndDismiss(pn: TCalloutPanel);
begin
  pn.AnimateFloat('Opacity', 1.0, 0.3);
  pn.AnimateFloatDelay('Opacity', 0.0, 0.7, 3.0);
end;

procedure TfrmSettings.FormActivate(Sender: TObject);
begin
  WindowState := TWindowState.wsMaximized;
  tbSettings.BringToFront;
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  //general init
  self.SyncBucketList;

  //init oss settings
  CopyBitmap(self.lbiOssSettings.Icon, frmMain.imgOssOn.Bitmap); //selected by default
  self.pnValidateProgress.Opacity := 0.0;
  self.pnValidateSuccess.Opacity := 0.0;
  self.pnValidateError.Opacity := 0.0;
  self.ReadOss;

  //init mail settings
  CopyBitmap(self.lbiMailSettings.Icon, frmMain.imgMailOff.Bitmap);
  self.pnMailSaveSuccess.Opacity := 0.0;
  self.rbSMTPLoginOn.IsChecked := true;
  self.ReadMail;
end;

procedure TfrmSettings.FormGesture(Sender: TObject;
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

procedure TfrmSettings.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkEscape then
    Close;
end;

procedure TfrmSettings.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button = TMouseButton.mbRight then
    ShowToolbar(True)
  else
    ShowToolbar(False);
end;

procedure TfrmSettings.WriteMail;
begin
  try
    frmMain.IniData.MailHostname := self.edMailHostname.Text;
    frmMain.IniData.MailSMTPLogin := self.rbSMTPLoginOn.IsChecked;
    frmMain.IniData.MailBucket := self.cbMailBucket.Text;

    frmMain.AddLog('保存邮件服务器配置');
  except

  end;
end;

procedure TfrmSettings.WriteOss;
begin
  try
    frmMain.IniData.OssHostname := self.cbOssHost.Selected.Text;
    frmMain.IniData.AccessId := self.edOssAccessId.Text;
    frmMain.IniData.AccessKey := self.edOssAccessKey.Text;

    frmMain.AddLog('保存阿里云OSS服务配置');
  except

  end;
end;

procedure TfrmSettings.ShowToolbar(AShow: Boolean);
begin
  ppToolbar.Width := ClientWidth;
  ppToolbar.PlacementRectangle.Rect := TRectF.Create(0, ClientHeight-ppToolbar.Height, ClientWidth-1, ClientHeight-1);
  ppToolbarAnimation.StartValue := ppToolbar.Height;
  ppToolbarAnimation.StopValue := 0;

  ppToolbar.IsOpen := AShow;
end;


procedure TfrmSettings.SyncBucketList;
begin
  self.cbMailBucket.Items.Clear;
  self.cbMailBucket.Items.AddStrings(frmMain.CachedBuckets);
end;

procedure TfrmSettings.ToolbarCloseButtonClick(Sender: TObject);
begin
  Close;
end;

function TfrmSettings.ValidateMail: boolean;
begin
  result :=
    (self.edMailHostname.Text <> '') and
    (self.cbMailBucket.Text <> '')
end;

end.
