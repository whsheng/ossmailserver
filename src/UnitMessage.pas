unit UnitMessage;

{
  OSS Mail Server v1.0.0 - Message Form

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
  System.SysUtils, System.Types, System.UITypes, System.Rtti, System.Classes,
  System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs;

type
  TfrmMessage = class(TForm)
    styleMessage: TStyleBook;
    btnPrimary: TButton;
    laTitle: TLabel;
    laMessage: TLabel;
    btnSecondary: TButton;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    title, msg, btn1, btn2: string;
    function Popup(const title, msg, btn1: string; const btn2: string = ''): integer;
  public
    { Public declarations }
  end;

function MessageDlg(const title, msg, btn1: string; const btn2: string = ''): integer;

var
  frmMessage: TfrmMessage;

implementation

{$R *.fmx}

{ TfrmMessage }

function TfrmMessage.Popup(const title, msg, btn1, btn2: string): integer;
begin
  self.title := title;
  self.msg := msg;
  self.btn1 := btn1;
  self.btn2 := btn2;
  result := self.ShowModal;
end;

procedure TfrmMessage.FormShow(Sender: TObject);
var
  h, w: integer;
begin
  h := Application.MainForm.Height;
  w := Application.MainForm.Width;

  self.Top := (h - self.Height) div 2;
  self.Left := 0;
  self.Width := w;

  self.laTitle.Text := self.title;
  self.laMessage.Text := self.msg;
  self.btnPrimary.Text := self.btn1;
  self.btnSecondary.Text := self.btn2;

  if self.btn2 = '' then
  begin
    self.btnSecondary.Visible := false;
    self.btnPrimary.Position.X := self.btnSecondary.Position.X;
  end
end;

function MessageDlg(const title, msg, btn1, btn2: string): integer;
var
  frmMessage: TfrmMessage;
begin
  frmMessage := TfrmMessage.Create(nil);
  result := frmMessage.Popup(title, msg, btn1, btn2);
  frmMessage.Free;
end;

end.
