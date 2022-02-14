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
    ClearBtn: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure DFileMemoChange(Sender: TObject);
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

//Создаём новый образ по сценарию Dockerfile
procedure TDFileForm.BitBtn1Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  Application.ProcessMessages;
  DFileMemo.Lines.SaveToFile(GetUserDir + '.config/DockerManager/Dockerfile');

  //Если сборка из DockerHub
  if Trim(NewImageEdit.Text) <> '' then
    DockerCmd := 'cd ~/.config/DockerManager; docker build --tag ' +
      NewImageEdit.Text + ' .'
  else
    DockerCmd := 'cd ~/.config/DockerManager; docker build .';

  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;

  DFileForm.Close;
end;

procedure TDFileForm.BitBtn2Click(Sender: TObject);
begin
  DFileForm.Close;
end;

procedure TDFileForm.DFileMemoChange(Sender: TObject);
begin
  if Trim(DFileMemo.Text) = '' then BitBtn1.Enabled := False
  else
    BitBtn1.Enabled := True;
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

  ClearBtn.Width := NewImageEdit.Height;

  if FileExists(GetUserDir + '.config/DockerManager/Dockerfile') then
    DFileMemo.Lines.LoadFromFile(GetUserDir + '.config/DockerManager/Dockerfile');

  if DFileForm.Caption <> SDockerHub then
    DFileMemo.Lines[0] := 'FROM ' + DFileForm.Caption;
end;

end.
