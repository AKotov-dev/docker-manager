unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, ComCtrls, Process, DefaultTranslator, IniPropStorage;

type

  { TMainForm }

  TMainForm = class(TForm)
    ImageBox: TListBox;
    ContainerBox: TListBox;
    IniPropStorage1: TIniPropStorage;
    LogMemo: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    N8: TMenuItem;
    N7: TMenuItem;
    N6: TMenuItem;
    N5: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    N4: TMenuItem;
    N3: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    StaticText1: TStaticText;
    procedure FormShow(Sender: TObject);
    procedure ImageBoxDrawItem(Control: TWinControl; Index: integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure StartProcess(command: string);

  private

  public

  end;

var
  MainForm: TMainForm;
  DockerCmd: string;

resourcestring
  SPullCaption = 'Pull image';
  SPullString = 'Enter name:tag';
  SRunImage = 'Run image';
  SRunImageCommand = 'Enter the parameters (sample: -p 8080:80 or echo "hello")';
  SRunImageRm = 'Run image with --rm';
  SDockerNotRunning =
    'Docker Manager: Warning! Docker not running or no superuser privileges!';
  SCreateImageCaption = 'Create a new Image';
 { SExecCaption = 'Execute';
  SExecString = 'Enter the command';}

implementation

uses docker_images_trd, docker_containers_trd, start_docker_command;

{$R *.lfm}

{ TMainForm }

//StartCommand (служебные команды)
procedure TMainForm.StartProcess(command: string);
var
  ExProcess: TProcess;
begin
  try
    ExProcess := TProcess.Create(nil);
    ExProcess.Executable := 'bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(command);
    ExProcess.Options := [poUsePipes]; //, poStderrToOutPut, poWaitOnExit
    ExProcess.Execute;
    MainForm.LogMemo.Lines.LoadFromStream(ExProcess.Output);
  finally
    ExProcess.Free;
  end;
end;

//Функция вычисления image:tag
function ImageTag: string;
var
  s: string;
  i, a: integer;
begin
  a := 0;
  s := '';
  with MainForm do
  begin
    for i := 0 to Length(ImageBox.Items[ImageBox.ItemIndex]) - 1 do
    begin
      if ImageBox.Items[ImageBox.ItemIndex][i] = ' ' then
      begin
        S := Copy(ImageBox.Items[ImageBox.ItemIndex], 1, i - 1) + ':';
        a := i;
        break;
      end;
    end;

    for i := a to Length(ImageBox.Items[ImageBox.ItemIndex]) - 1 do
    begin
      if ImageBox.Items[ImageBox.ItemIndex][i] = ' ' then
        a := i
      else
        Break;
    end;

    for i := a + 1 to Length(ImageBox.Items[ImageBox.ItemIndex]) - 1 do
    begin
      if ImageBox.Items[ImageBox.ItemIndex][i] = ' ' then
        break
      else
        S := S + ImageBox.Items[ImageBox.ItemIndex][i];
    end;
  end;
  Result := S;
end;

//Функция вычисления ID контейнера
function ContainerID: string;
var
  s: string;
  i: integer;
begin
  s := '';

  with MainForm do
  begin
    for i := 0 to Length(ContainerBox.Items[ContainerBox.ItemIndex]) - 1 do
    begin
      if ContainerBox.Items[ContainerBox.ItemIndex][i] = ' ' then
      begin
        S := Copy(ContainerBox.Items[ContainerBox.ItemIndex], 1, i - 1);
        break;
      end;
    end;
  end;
  Result := S;
end;

//Запуск потоков
procedure TMainForm.FormShow(Sender: TObject);
var
  FDImages, FDContainers: TThread;
begin
  if not DirectoryExists(GetUserDir + '.config') then
    mkDir(GetUserDir + '.config');
  IniPropStorage1.IniFileName := GetUserDir + '.config/docker-manager.conf';

  IniPropStorage1.Restore;

  ImageBox.ScrollWidth := 0;
  ContainerBox.ScrollWidth := 0;

  MainForm.Caption := Application.Title;

  DockerCmd := '';
  ImageBox.ItemHeight := ImageBox.Font.Size + 10;
  ContainerBox.ItemHeight := ImageBox.ItemHeight;

  FDImages := DImages.Create(False);
  FDImages.Priority := tpHighest;

  FDContainers := DContainers.Create(False);
  FDContainers.Priority := tpHighest;

  //Проверка активности docker.service
  StartProcess('[[ $(systemctl is-active docker) != "active" ]] && echo "' +
    SDockerNotRunning + '"');
end;

//Раскрашивание ListBox
procedure TMainForm.ImageBoxDrawItem(Control: TWinControl; Index: integer;
  ARect: TRect; State: TOwnerDrawState);
begin
  with (Control as TListBox).Canvas do
  begin
    //Index
    if Index = 0 then
    begin
      Font.Color := clWhite;
      //Здесь любой цвет и другие параметры шрифта
      Font.Style := Font.Style + [fsBold];
      Brush.Color := clGreen;
    end;
    //Окончание блока данных
    if Copy((Control as TListBox).Items[Index], 0, 3) = '^^^' then
    begin
      Font.Color := clRed;
      Brush.Color := clMoneyGreen;
    end;

    FillRect(aRect);
    TextOut(aRect.Left + 2, aRect.Top + 2, (Control as TListBox).Items[Index]);
  end;
end;

procedure TMainForm.MenuItem10Click(Sender: TObject);
begin
  StartProcess('sakura -c 120 -r 40 -f 10 -x "docker run -it --rm ' +
    ImageTag + ' /bin/bash"');
end;

//Информация о версии контейнера
procedure TMainForm.MenuItem11Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  DockerCmd := Trim('docker inspect ' + ContainerID);
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Создаём свой образ из контейнера
procedure TMainForm.MenuItem12Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
  s: string;
begin
  S := '';
  repeat
    if not InputQuery(SCreateImageCaption, SPullString, S) then
      Exit
  until S <> '';

  DockerCmd := Trim('docker commit -a "' + GetEnvironmentVariable('USER') +
    '" ' + ContainerID + ' ' + S);

  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Backup Image
procedure TMainForm.MenuItem13Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  if SaveDialog1.Execute then
  begin
    DockerCmd := Trim('docker save -o "' + SaveDialog1.FileName + '" ' + ImageTag);
    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Restore Image
procedure TMainForm.MenuItem14Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  if OpenDialog1.Execute then
  begin
    DockerCmd := Trim('docker load -i "' + OpenDialog1.FileName + '"');
    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Execute a command inside a container
{procedure TMainForm.MenuItem15Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
  S: string;
begin
  S := '';
  repeat
    if not InputQuery(SExecCaption, SExecString, S) then
      Exit
  until S <> '';
  //Если контейнер не запущен - запускаем и выполняем команду
  DockerCmd := '[[ $(docker ps | grep ' + ContainerID + ') ]] || docker start ' +
    ContainerID + ' && docker exec -i ' + ContainerID + ' ' + Trim(S);

  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;}

//Старт Image с параметрами
procedure TMainForm.MenuItem1Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
  S: string;
begin
  S := '';
  if InputQuery(SRunImage, SRunImageCommand, S) then
    //Внутренняя или внешняя команда?
  begin
    if Pos('-', S) <> 0 then
      DockerCmd := Trim('docker run ' + S + ' ' + ImageTag)
    else
      DockerCmd := Trim('docker run ' + ImageTag + ' ' + S);

    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Удаление образа
procedure TMainForm.MenuItem2Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  DockerCmd := 'docker rmi ' + ImageTag;
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Старт контейнера с параметрами
procedure TMainForm.MenuItem3Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  DockerCmd := Trim('docker start ' + ContainerID);
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Стоп контейнера
procedure TMainForm.MenuItem4Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  DockerCmd := 'docker stop ' + ContainerID;
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Удаление контейнера
procedure TMainForm.MenuItem5Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  DockerCmd := 'docker rm ' + ContainerID;
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Войти в Shell запущенного контейнера
procedure TMainForm.MenuItem6Click(Sender: TObject);
begin
  StartProcess('[[ $(docker ps | grep ' + ContainerID + ') ]] || docker start ' +
    ContainerID + '&& sakura -c 120 -r 40 -f 10 -x "docker exec -it ' +
    ContainerID + ' /bin/bash"');
end;

//Получение Docker-Image
procedure TMainForm.MenuItem7Click(Sender: TObject);
var
  S: string;
  FStartDockerCommand: TThread;
begin
  S := '';
  repeat
    if not InputQuery(SPullCaption, SPullString, S) then
      Exit
  until S <> '';

  DockerCmd := 'docker pull ' + Trim(S);
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Старт Docker-Image с командой --rm
procedure TMainForm.MenuItem8Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
  s: string;
begin
  S := '';
  if InputQuery(SRunImageRm, SRunImageCommand, S) then
    //Внутренняя или внешняя команда?
  begin
    if Pos('-', S) <> 0 then
      DockerCmd := Trim('docker run --rm ' + S + ' ' + ImageTag)
    else
      DockerCmd := Trim('docker run --rm ' + ImageTag + ' ' + S);

    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Запуск образа и вход в BASH
procedure TMainForm.MenuItem9Click(Sender: TObject);
begin
  StartProcess('sakura -c 120 -r 40 -f 10 -x "docker run -it ' +
    ImageTag + ' /bin/bash"');
end;

//Контроль меню образов
procedure TMainForm.PopupMenu1Popup(Sender: TObject);
var
  i: integer;
begin
  Application.ProcessMessages;
  if (ImageBox.Selected[0]) or (Pos('^^^', ImageBox.Items[ImageBox.ItemIndex]) <> 0) then
    for i := 1 to PopUpMenu1.Items.Count - 1 do
    begin
      if i <> 9 then
        PopUpMenu1.Items[i].Enabled := False;
    end
  else
    for i := 1 to PopUpMenu1.Items.Count - 1 do
      PopUpMenu1.Items[i].Enabled := True;
end;

//Контроль меню контейнеров
procedure TMainForm.PopupMenu2Popup(Sender: TObject);
var
  i: integer;
begin
  Application.ProcessMessages;
  if (ContainerBox.Selected[0]) or
    (Pos('^^^', ContainerBox.Items[ContainerBox.ItemIndex]) <> 0) then
    for i := 0 to PopUpMenu2.Items.Count - 1 do
      PopUpMenu2.Items[i].Enabled := False
  else
    for i := 0 to PopUpMenu2.Items.Count - 1 do
      PopUpMenu2.Items[i].Enabled := True;
end;

end.
