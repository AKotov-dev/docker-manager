unit dockerfile_unit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  IniPropStorage, LCLType;

type

  { TDFileForm }

  TDFileForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DFileMemo: TMemo;
    Label1: TLabel;
    NewImageEdit: TEdit;
    IniPropStorage1: TIniPropStorage;
    DfDirBtn: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure DfDirBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NewImageEditChange(Sender: TObject);
    procedure NewImageEditKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
  private

  public

  end;

var
  DFileForm: TDFileForm;

implementation

uses unit1, start_docker_command, project_files;

  {$R *.lfm}

  { TDFileForm }

//Создаём новый образ по сценарию Dockerfile
procedure TDFileForm.BitBtn1Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  Application.ProcessMessages;
  DFileMemo.Lines.SaveToFile(GetUserDir + 'DockerManager/Dockerfile');

  //Сборка нового образа
  DockerCmd := 'cd ~/DockerManager; docker build --tag ' +
    NewImageEdit.Text + ' .';

  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;

  DFileForm.Close;
end;

procedure TDFileForm.BitBtn2Click(Sender: TObject);
begin
  DFileForm.Close;
end;

//Файлы проекта
procedure TDFileForm.DfDirBtnClick(Sender: TObject);
begin
  FilesForm.Show;
end;

procedure TDFileForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IniPropStorage1.Save;
end;

procedure TDFileForm.FormCreate(Sender: TObject);
begin
  //Файл конфигурации формы Dockerfile
  IniPropStorage1.IniFileName := MainForm.IniPropStorage1.IniFileName;
end;

//Восстанавливаем последний созданный Dockerfile
procedure TDFileForm.FormShow(Sender: TObject);
begin
  IniPropStorage1.Restore;

  if FileExists(GetUserDir + 'DockerManager/Dockerfile') then
    DFileMemo.Lines.LoadFromFile(GetUserDir + 'DockerManager/Dockerfile');

 { if DFileForm.Caption <> SDockerHub then
    DFileMemo.Lines[0] := 'FROM ' + DFileForm.Caption;}
end;

//Имя_образа:тэг задаём обязательно
procedure TDFileForm.NewImageEditChange(Sender: TObject);
begin
  if NewImageEdit.Text = '' then BitBtn1.Enabled := False
  else
    BitBtn1.Enabled := True;
end;

//Запрет пробелов в имени нового образа
procedure TDFileForm.NewImageEditKeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then Key := 0;
end;

end.
