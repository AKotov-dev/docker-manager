unit login_unit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  IniPropStorage, start_docker_command;

type

  { TLoginForm }

  TLoginForm = class(TForm)
    LogoutBtn: TBitBtn;
    IniPropStorage1: TIniPropStorage;
    LoginBtn: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LoginBtnClick(Sender: TObject);
    procedure LogoutBtnClick(Sender: TObject);
  private

  public

  end;

var
  LoginForm: TLoginForm;

implementation

uses unit1;

  {$R *.lfm}

  { TLoginForm }

//Login to DockerHub (Name/Password)
procedure TLoginForm.LoginBtnClick(Sender: TObject);
var
  DockerCmd: String;
begin
  LoginForm.Close;
  DockerCmd := Trim('docker login -u ' + Trim(Edit1.Text) + ' -p ' + Trim(Edit2.Text));
  TStartDockerCommand.Create(DockerCmd);
end;

//Файл настроек
procedure TLoginForm.FormCreate(Sender: TObject);
begin
  IniPropStorage1.IniFileName := MainForm.IniPropStorage1.IniFileName;
end;

//Сохранение размеров формы для Plasma
procedure TLoginForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IniPropStorage1.Save;
end;

//Восстановление размеров формы для Plasma
procedure TLoginForm.FormShow(Sender: TObject);
begin
  IniPropStorage1.Restore;
  Edit1.SetFocus;
end;

//Logout from Docker
procedure TLoginForm.LogoutBtnClick(Sender: TObject);
var
  DockerCmd: String;
begin
  LoginForm.Close;
  DockerCmd := Trim('docker logout');
  TStartDockerCommand.Create(DockerCmd);
end;

end.
