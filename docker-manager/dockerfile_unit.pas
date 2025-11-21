unit dockerfile_unit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  IniPropStorage, LCLType, start_docker_command;

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
    SaveBtn: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure DfDirBtnClick(Sender: TObject);
    procedure DFileMemoChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NewImageEditChange(Sender: TObject);
    procedure NewImageEditKeyDown(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure SaveBtnClick(Sender: TObject);
  private

  public

  end;

var
  DFileForm: TDFileForm;
  SaveFlag: boolean;

implementation

uses unit1, project_files;

  {$R *.lfm}

  { TDFileForm }

//Создаём новый образ по сценарию Dockerfile
procedure TDFileForm.BitBtn1Click(Sender: TObject);
var
  DockerCmd: string;
begin
  Application.ProcessMessages;
  //Сохраняем Dockerfile
  SaveBtn.Click;

  //Сборка нового образа
  DockerCmd := 'cd ~/DockerManager; docker build --tag ' + NewImageEdit.Text + ' .';

  TStartDockerCommand.Create(DockerCmd);

  SaveFlag := False;

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

//Флаг редактирования
procedure TDFileForm.DFileMemoChange(Sender: TObject);
begin
  SaveFlag := True;
end;

procedure TDFileForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IniPropStorage1.Save;

  if SaveFlag then if MessageDlg(SDockerfileSave, mtConfirmation,
      [mbYes, mbNo], 0) = mrYes then
      SaveBtn.Click;
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

  //Если Doсkerfile существует - показываем, иначе создаём новый
  if FileExists(GetUserDir + 'DockerManager/Dockerfile') then
    DFileMemo.Lines.LoadFromFile(GetUserDir + 'DockerManager/Dockerfile')
  else
    DFileMemo.Lines.SaveToFile(GetUserDir + 'DockerManager/Dockerfile');

  SaveFlag := False;
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

//Сохраняем Dockerfile
procedure TDFileForm.SaveBtnClick(Sender: TObject);
begin
  DFileMemo.Lines.SaveToFile(GetUserDir + 'DockerManager/Dockerfile');
  SaveFlag := False;
end;

end.
