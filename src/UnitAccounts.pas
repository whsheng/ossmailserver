unit UnitAccounts;

{
  OSS Mail Server v1.0.0 - Accounts Form

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
  TfrmAccounts = class(TForm)
    styleSettings: TStyleBook;
    loToolbar: TLayout;
    ppToolbar: TPopup;
    ppToolbarAnimation: TFloatAnimation;
    loAccounts: TLayout;
    loMenu: TLayout;
    lbAccounts: TListBox;
    lbiAddAccount: TMetropolisUIListBoxItem;
    loMenuHeader: TLayout;
    laMenuTitle: TLabel;
    loBack: TLayout;
    btnBack: TButton;
    loParameters: TLayout;
    tbSettings: TToolBar;
    ToolbarApplyButton: TButton;
    ToolbarCloseButton: TButton;
    ToolbarAddButton: TButton;
    tcAccount: TTabControl;
    sbAccounts: THorzScrollBox;
    tiAccount: TTabItem;
    sbAccount: TVertScrollBox;
    loAccountHeader: TLayout;
    imgAccountIcon: TImageControl;
    loAccountTitles: TLayout;
    laAccountTitle: TLabel;
    laAccountSubTitle: TLabel;
    laUsername: TLabel;
    edUsername: TEdit;
    ClearEditButton3: TClearEditButton;
    laPassword: TLabel;
    pnPassword: TPanel;
    laAccountStatus: TLabel;
    pnAccountStatus: TPanel;
    rbAccountLocked: TRadioButton;
    rbAccountNotLocked: TRadioButton;
    pnAccountOperation: TPanel;
    btnAccountSave: TButton;
    pnAccountSaveSuccess: TCalloutPanel;
    lbAccountSaveSuccess: TLabel;
    edPassword: TEdit;
    PasswordEditButton1: TPasswordEditButton;
    lbiAccountTemplate: TMetropolisUIListBoxItem;
    btnAccountDelete: TButton;
    laGuid: TLabel;
    edGuid: TEdit;
    procedure btnBackClick(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure ToolbarCloseButtonClick(Sender: TObject);
    procedure lbiAddAccountClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbiAccountTemplateClick(Sender: TObject);
    procedure btnAccountDeleteClick(Sender: TObject);
    procedure btnAccountSaveClick(Sender: TObject);
  private
    FGestureOrigin: TPointF;
    FGestureInProgress: Boolean;
    { Private declarations }
    procedure ShowToolbar(AShow: Boolean);

    procedure LoadAccountList;

    procedure ReadAccount(index: integer);
    function ValidateAccount: boolean;
    procedure WriteAccount(index: integer);

    procedure FlashAndDismiss(pn: TCalloutPanel);

    procedure SwitchAccountIcon(Sender: TObject);

    function GenerateGUID: string;
  public
    { Public declarations }
  end;

var
  frmAccounts: TfrmAccounts;

implementation

{$R *.fmx}

uses ALIOSSUTIL, UnitMain, UnitMessage, ComObj;

procedure SelectItem(cb: TComboBox; item: string);
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

procedure TfrmAccounts.btnAccountDeleteClick(Sender: TObject);
begin
  //delete current user
  if IdYes = MessageDlg('确认', '即将删除用户“'+self.laAccountTitle.Text+'”，确认删除吗？', '确定', '取消') then
  begin
    frmMain.IniData.Accounts.Delete(self.laAccountTitle.Tag);

    //reload account list
    self.LoadAccountList;
    self.lbAccounts.ItemIndex := 0;
    self.lbiAddAccountClick(self.lbiAddAccount);
  end;
end;

procedure TfrmAccounts.btnAccountSaveClick(Sender: TObject);
begin
  if not self.ValidateAccount then
  begin
    MessageDlg('提示', '保用户失败，请检查设置。', '确定');
    exit;
  end;

  self.WriteAccount(self.laAccountTitle.Tag);
  frmMain.SaveIniFile;
  FlashAndDismiss(self.pnAccountSaveSuccess);

  //reload account list
  self.LoadAccountList;
end;

procedure TfrmAccounts.btnBackClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAccounts.lbiAccountTemplateClick(Sender: TObject);
var
  lb: TMetropolisUIListBoxItem;
begin
  self.SwitchAccountIcon(Sender);

  lb := Sender as TMetropolisUIListBoxItem;
  self.laAccountTitle.Tag := lb.Tag;
  self.laAccountTitle.Text := lb.Title;

  self.pnAccountSaveSuccess.Opacity := 0.0;
  self.btnAccountDelete.Opacity := 1.0;

  //load account data
  self.ReadAccount(lb.Tag);
end;

procedure TfrmAccounts.lbiAddAccountClick(Sender: TObject);
begin
  self.SwitchAccountIcon(Sender);

  self.laAccountTitle.Tag := -1;
  self.laAccountTitle.Text := '添加用户';

  self.pnAccountSaveSuccess.Opacity := 0.0;
  self.btnAccountDelete.Opacity := 0.0;

  //new account
  self.ReadAccount(-1);
end;

procedure TfrmAccounts.LoadAccountList;
var
  I: Integer;
  data: string;
  username: string;
  lb: TMetropolisUIListBoxItem;
begin
  //clear current items
  for I := self.lbAccounts.Count - 1 downto 1 do
  begin
    self.lbAccounts.Items.Delete(I);
  end;

  for I := 0 to frmMain.IniData.Accounts.Count - 1 do
  begin
    data := frmMain.IniData.Accounts[I];
    PopString(data);
    username := PopString(data);
    lb := self.lbiAccountTemplate.Clone(self.lbAccounts) as TMetropolisUIListBoxItem;
    lb.Name := 'lbAccount'+IntToStr(i+1);
    lb.Title := StringReplace(lb.Title, '{username}', username, [rfReplaceAll]);
    lb.SubTitle := StringReplace(lb.SubTitle, '{username}', username, [rfReplaceAll]);
    lb.Visible := true;
    lb.Tag := i;
    lb.OnClick := self.lbiAccountTemplateClick;
    lb.Parent := self.lbAccounts;
  end;
end;

procedure TfrmAccounts.ReadAccount(index: integer);
var
  data: string;
  guid: string;
  username: string;
  password: string;
  locked: boolean;
begin
  try
    if index = -1 then
      data := self.GenerateGUID
    else
      data := frmMain.IniData.Accounts[index];

    //split data
    //guid|username|password|true/false
    guid := PopString(data);
    username := PopString(data);
    password := PopString(data);
    locked := data = 'true';

    self.edGuid.Text := guid;
    self.edUsername.Text := username;
    self.edPassword.Text := password;
    self.rbAccountLocked.IsChecked := locked;
    self.rbAccountNotLocked.IsChecked := not locked;
    if index <> -1 then
      self.laAccountTitle.Text := username;
  except

  end;
end;

procedure TfrmAccounts.FlashAndDismiss(pn: TCalloutPanel);
begin
  pn.AnimateFloat('Opacity', 1.0, 0.3);
  pn.AnimateFloatDelay('Opacity', 0.0, 0.7, 3.0);
end;

procedure TfrmAccounts.FormActivate(Sender: TObject);
begin
  WindowState := TWindowState.wsMaximized;
  tbSettings.BringToFront;
end;

procedure TfrmAccounts.FormCreate(Sender: TObject);
begin
  //init account settings
  CopyBitmap(self.lbiAddAccount.Icon, frmMain.imgAddAccountOn.Bitmap); //selected by default
  CopyBitmap(self.lbiAccountTemplate.Icon, frmMain.imgAccountsOff.Bitmap);

  //load account list
  self.lbiAccountTemplate.Parent := self;
  self.LoadAccountList;

  self.lbiAddAccountClick(self.lbiAddAccount);
end;

procedure TfrmAccounts.FormGesture(Sender: TObject;
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

procedure TfrmAccounts.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkEscape then
    Close;
end;

procedure TfrmAccounts.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button = TMouseButton.mbRight then
    ShowToolbar(True)
  else
    ShowToolbar(False);
end;

function TfrmAccounts.GenerateGUID: string;
begin
  result := CreateClassID;
  result := copy(result, 2, length(result)-2); //remove {}
end;

procedure TfrmAccounts.WriteAccount(index: integer);
var
  data: string;
begin
  try
    if self.rbAccountLocked.IsChecked then
      data := 'true'
    else
      data := 'false';
    data := self.edGuid.Text+'|'+self.edUsername.Text+'|'+self.edPassword.Text+'|'+data;
    if index = -1 then
    begin
      //new user
      frmMain.IniData.Accounts.Add(data);
    end
    else
    begin
      //save existing user
      frmMain.IniData.Accounts[index] := data;
      self.laAccountTitle.Text := self.edUsername.Text;
      (self.lbAccounts.Selected as TMetropolisUIListBoxItem).Title := self.edUsername.Text;
    end;
    frmMain.AddLog('保存用户列表');
  except

  end;
end;

procedure TfrmAccounts.ShowToolbar(AShow: Boolean);
begin
  ppToolbar.Width := ClientWidth;
  ppToolbar.PlacementRectangle.Rect := TRectF.Create(0, ClientHeight-ppToolbar.Height, ClientWidth-1, ClientHeight-1);
  ppToolbarAnimation.StartValue := ppToolbar.Height;
  ppToolbarAnimation.StopValue := 0;

  ppToolbar.IsOpen := AShow;
end;


procedure TfrmAccounts.SwitchAccountIcon(Sender: TObject);
var
  lb: TMetropolisUIListBoxItem;
  I: integer;
begin
  for I := 0 to self.lbAccounts.Count - 1 do
  begin
    lb := self.lbAccounts.ItemByIndex(I) as TMetropolisUIListBoxItem;
    if lb.TagString = 'on' then
    begin
      //last selected
      if I = 0 then
        frmMain.SwitchIcon(lb, 'imgAddAccountOff')
      else
        frmMain.SwitchIcon(lb, 'imgAccountsOff');
      lb.TagString := '';
      break;
    end;
  end;

  //new account
  lb := Sender as TMetropolisUIListBoxItem;
  if lb = self.lbAccounts.ItemByIndex(0) then
    frmMain.SwitchIcon(lb, 'imgAddAccountOn')
  else
    frmMain.SwitchIcon(lb, 'imgAccountsOn');
  lb.TagString := 'on';
end;

procedure TfrmAccounts.ToolbarCloseButtonClick(Sender: TObject);
begin
  Close;
end;

function TfrmAccounts.ValidateAccount: boolean;
var
  I: Integer;
  data: string;
  guid: string;
  username: string;
begin
  result :=
    (self.edUsername.Text <> '') and
    (self.edPassword.Text <> '') and
    (self.rbAccountLocked.IsChecked or self.rbAccountNotLocked.IsChecked);
  if result then
  begin
    for I := 0 to frmMain.IniData.Accounts.Count - 1 do
    begin
      data := frmMain.IniData.Accounts[I];
      guid := PopString(data);
      username := PopString(data);
      //check unique guid
      if (self.laAccountTitle.Tag = -1) and (guid = self.edGuid.Text) then
      begin
        result := false;
        break;
      end;
      //check unique username
      if (username = self.edUsername.Text) and (guid <> self.edGuid.Text) then
      begin
        result := false;
        break;
      end;
    end;
  end;
end;

end.
