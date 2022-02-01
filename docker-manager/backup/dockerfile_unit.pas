unit dockerfile_unit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  IniPropStorage;

type

  { TDFileForm }

  TDFileForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DFileMemo: TMemo;
    Label1: TLabel;
    NewImageEdit: TEdit;
    IniPropStorage1: TIniPropStorage;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  DFileForm: TDFileForm;

implementation

uses unit1, start_docker_command;

{$R *.lfm}

{ TDFileForm }

//Правим исходный образ (или создаём новый) по сценарию Dockerfile
procedure TDFileForm.BitBtn1Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  Application.ProcessMessages;
  DFileMemo.Lines.SaveToFile(GetUserDir + '.config/DockerManager/Dockerfile');

  if Trim(NewImageEdit.Text) = '' then
    DockerCmd := 'cd ~/.config/DockerManager; docker build -t ' +
      DFileForm.Caption + ' .'
  else
    DockerCmd := 'cd ~/.config/DockerManager; docker build -t ' +
      DFileForm.Caption + ' . --tag ' + NewImageEdit.Text;

  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;

  DFileForm.Close;
end;

procedure TDFileForm.BitBtn2Click(Sender: TObject);
begin
  DFileForm.Close;
end;

procedure TDFileForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IniPropStorage1.Save;
end;

procedure TDFileForm.FormCreate(Sender: TObject);
begin
  //Файл конфигурации формы Dockerfile
  DFileForm.IniPropStorage1.IniFileName := IniPropStorage1.IniFileName;
end;

//Восстанавливаем последний созданный Dockerfile
procedure TDFileForm.FormShow(Sender: TObject);
begin
  IniPropStorage1.Restore;

  if FileExists(GetUserDir + '.config/DockerManager/Dockerfile') then
    DFileMemo.Lines.LoadFromFile(GetUserDir + '.config/DockerManager/Dockerfile');

  DFileMemo.Lines[0] := 'FROM ' + DFileForm.Caption;
end;

end.
