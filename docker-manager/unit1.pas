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
    ImageList1: TImageList;
    IniPropStorage1: TIniPropStorage;
    LogMemo: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    Separator3: TMenuItem;
    Separator2: TMenuItem;
    Separator1: TMenuItem;
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
    procedure ContainerBoxDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImageBoxDblClick(Sender: TObject);
    procedure ImageBoxDrawItem(Control: TWinControl; Index: integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem15Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem21Click(Sender: TObject);
    procedure MenuItem22Click(Sender: TObject);
    procedure MenuItem23Click(Sender: TObject);
    procedure MenuItem24Click(Sender: TObject);
    procedure MenuItem25Click(Sender: TObject);
    procedure MenuItem26Click(Sender: TObject);
    procedure MenuItem28Click(Sender: TObject);
    procedure MenuItem29Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure StartProcess(command: string);
    procedure ImageMenuControl;
    procedure ContainerMenuControl;


  private

  public

  end;

var
  MainForm: TMainForm;
  //DockerCmd - команда в поток, RunImageCmd + ImageName - для InputQuery на время сеанса работы
  DockerCmd, RunImageCmd, ImageName: string;

resourcestring
  SPullCaption = 'Pull image';
  SPullString = 'Enter name:tag';
  SRunImage = 'Run image';
  SRunImageCommand = 'Enter the parameters (sample: -p 8080:80 or echo "hello")';
  SRunImageRm = 'Run image with --rm';
  SCreateImageCaption = 'Create a new Image';
  SConfirmDeletion = 'Do you confirm the deletion?';
  SDockerHub = '...the main image is not selected; will be retrieved from DockerHub';
  SDeleteFile = 'Delete selected files?';
  SImportTarFile = 'Import from a tar archive';
  SRenameCaption = 'Renaming';
  SRenameString = 'Enter a new name:';
  SDockerNotRunning =
    'Warning! Docker not running! Launch Docker: systemctl restart docker.service';
  SNoUserInDocker =
    'Warning! Include the user in the docker group and restart the computer: usermod -aG docker $LOGNAME; reboot';

 { SExecCaption = 'Execute';
  SExecString = 'Enter the command';}

implementation

uses dockerfile_unit, docker_images_trd, docker_containers_trd,
  start_docker_command, terminal_trd, login_unit;

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
  L, R: string;
  i, a: integer;
begin
  a := 0;
  R := '';
  with MainForm do
  begin
    //Первый пробел сначала после слова
    a := Pos(' ', ImageBox.Items[ImageBox.ItemIndex]);
    //Левая часть ImageTag до :
    L := Copy(ImageBox.Items[ImageBox.ItemIndex], 1, a - 1) + ':';

    //Листаем пробелы до первого знака
    for i := a to Length(ImageBox.Items[ImageBox.ItemIndex]) - 1 do
      if ImageBox.Items[ImageBox.ItemIndex][i] = ' ' then
        a := i
      else
        Break;
    //(a -1) - индекс начала второго слова. Пробелы пройдены

    //Часть строки, начиная с нужного символа до конца
    { R := Copy(ImageBox.Items[ImageBox.ItemIndex], a + 1,
      Length(ImageBox.Items[ImageBox.ItemIndex]));
    //R - правая часть ContainerID
      R := Copy(R, 1, Pos(' ', R) - 1); }

    R := Copy(Copy(ImageBox.Items[ImageBox.ItemIndex], a + 1,
      Length(ImageBox.Items[ImageBox.ItemIndex])), 1,
      Pos(' ', Copy(ImageBox.Items[ImageBox.ItemIndex], a + 1,
      Length(ImageBox.Items[ImageBox.ItemIndex]))) - 1);
  end;
  Result := Concat(L, R);
end;

{//Функция вычисления ID контейнера (заменена на ContainerName: 27.02.2022 для унификации)
function ContainerID: string;
begin
  with MainForm do
    Result := Copy(ContainerBox.Items[ContainerBox.ItemIndex], 1,
      Pos(' ', ContainerBox.Items[ContainerBox.ItemIndex]) - 1);
end;}

//Функция вычисления ContainerName
function ContainerName: string;
var
  i: integer;
begin
  Result := '';
  with MainForm do
    for i := Length(ContainerBox.Items[ContainerBox.ItemIndex]) downto 0 do
      if ContainerBox.Items[ContainerBox.ItemIndex][i] = ' ' then break
      else
        Result := ContainerBox.Items[ContainerBox.ItemIndex][i] + Result;
end;

//Функция вычисления NewImageName из строки контейнера (Создать образ из контейнера)
function NewImageName: string;
var
  i, a: integer;
begin
  a := 0;
  with MainForm do
  begin
    //Первый пробел сначала после слова
    a := Pos(' ', ContainerBox.Items[ContainerBox.ItemIndex]);

    //Листаем пробелы до первого знака
    for i := a to Length(ContainerBox.Items[ContainerBox.ItemIndex]) - 1 do
      if ContainerBox.Items[ContainerBox.ItemIndex][i] = ' ' then
        a := i
      else
        Break;
    //(a -1) - индекс начала второго слова. Пробелы пройдены

    Result := Copy(Copy(ContainerBox.Items[ContainerBox.ItemIndex],
      a + 1, Length(ContainerBox.Items[ContainerBox.ItemIndex])), 1,
      Pos(' ', Copy(ContainerBox.Items[ContainerBox.ItemIndex], a +
      1, Length(ContainerBox.Items[ContainerBox.ItemIndex]))) - 1);
  end;
end;

//Контроль PopUpMenu Images
procedure TMainForm.ImageMenuControl;
var
  i: integer;
begin
  try
    Application.ProcessMessages;
    if (ImageBox.Selected[0]) or
      (Pos('^^^', ImageBox.Items[ImageBox.ItemIndex]) <> 0) then
      for i := 1 to PopUpMenu1.Items.Count - 1 do
      begin
        if (i <> 3) and (i <> 13) and (i <> 15) then
          PopUpMenu1.Items[i].Enabled := False;
      end
    else
      for i := 1 to PopUpMenu1.Items.Count - 1 do
        PopUpMenu1.Items[i].Enabled := True;
  except
    abort;
  end;
end;

//Контроль PopUpMenu Containers
procedure TMainForm.ContainerMenuControl;
var
  i: integer;
begin
  try
    Application.ProcessMessages;
    if (ContainerBox.Selected[0]) or
      (Pos('^^^', ContainerBox.Items[ContainerBox.ItemIndex]) <> 0) then
      for i := 0 to PopUpMenu2.Items.Count - 1 do
        PopUpMenu2.Items[i].Enabled := False
    else
      for i := 0 to PopUpMenu2.Items.Count - 1 do
        PopUpMenu2.Items[i].Enabled := True;
  except
    abort;
  end;
end;

//Восстановление при масштабировании в Plasma
procedure TMainForm.FormShow(Sender: TObject);
begin
  IniPropStorage1.Restore;
end;

//Запуск контейнера DblClick с контролем пунктов PopUp-меню (enable/disable)
procedure TMainForm.ContainerBoxDblClick(Sender: TObject);
begin
  ContainerMenuControl;
  MenuItem3.Click;
end;

//Запуск потоков
procedure TMainForm.FormCreate(Sender: TObject);
var
  FDImages, FDContainers: TThread;
begin
  //Файл конфигурации
  if not DirectoryExists(GetUserDir + '.config') then
    mkDir(GetUserDir + '.config');
  IniPropStorage1.IniFileName := GetUserDir + '.config/docker-manager.conf';

  //Каталог для файла Dockerfile
  if not DirectoryExists(GetUserDir + '.config/DockerManager') then
    mkDir(GetUserDir + '.config/DockerManager');

  ImageBox.ScrollWidth := 0;
  ContainerBox.ScrollWidth := 0;

  MainForm.Caption := Application.Title;

  DockerCmd := '';
  ImageBox.ItemHeight := ImageBox.Font.Size + 10;
  ContainerBox.ItemHeight := ImageBox.ItemHeight;

  //Проверка активности docker.service и включение $USER в группу docker
  StartProcess('[[ $(systemctl is-active docker) != "active" ]] && echo "' +
    SDockerNotRunning + '"; [[ $(groups | grep "docker") ]] || echo "' +
    SNoUserInDocker + '"');

  FDImages := DImages.Create(False);
  FDImages.Priority := tpHighest;

  FDContainers := DContainers.Create(False);
  FDContainers.Priority := tpHighest;
end;

//Запуск образа DblClick с контролем пунктов PopUp-меню (enable/disable)
procedure TMainForm.ImageBoxDblClick(Sender: TObject);
begin
  ImageMenuControl;
  MenuItem1.Click;
end;

//Раскрашивание ImageBox и ContainerBox
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
var
  FStartTerminal: TThread;
begin
  DockerCmd := 'sakura -c 120 -r 40 -f 10 -x "docker run -it --rm ' +
    ImageTag + ' /bin/bash"';
  FStartTerminal := TerminalTRD.Create(False);
  FStartTerminal.Priority := tpNormal;
end;

//Вывод информации о версии контейнера
procedure TMainForm.MenuItem11Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  DockerCmd := Trim('docker inspect ' + ContainerName);
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Создать свой образ из контейнера
procedure TMainForm.MenuItem12Click(Sender: TObject);
var
  S: string;
  FStartDockerCommand: TThread;
begin
  S := NewImageName;
  repeat
    if not InputQuery(SCreateImageCaption, SPullString, S) then
      Exit
  until S <> '';

  DockerCmd := Trim('docker commit -a "' + GetEnvironmentVariable('USER') +
    '" ' + ContainerName + ' ' + Trim(S));

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
    DockerCmd := 'docker save -o "' + SaveDialog1.FileName + '" ' + ImageTag;
    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Restore Images
procedure TMainForm.MenuItem14Click(Sender: TObject);
var
  i: integer;
  FStartDockerCommand: TThread;
begin
  if OpenDialog1.Execute then
  begin
    for i := 0 to OpenDialog1.Files.Count - 1 do
      DockerCmd := DockerCmd + 'docker load -i "' + OpenDialog1.Files[i] + '"; ';
    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Удаление образа
procedure TMainForm.MenuItem15Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  if MessageDlg(SConfirmDeletion, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    DockerCmd := 'docker rmi ' + ImageTag;
    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Delete untagged Images
procedure TMainForm.MenuItem16Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  if MessageDlg(SConfirmDeletion, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    DockerCmd := 'docker image prune -f';
    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Delete Images without Containers
procedure TMainForm.MenuItem17Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  if MessageDlg(SConfirmDeletion, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    DockerCmd := 'docker image prune -f -a';
    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Удаление контейнера
procedure TMainForm.MenuItem18Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  if MessageDlg(SConfirmDeletion, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    DockerCmd := 'docker rm ' + ContainerName;
    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Удаление остановленных контейнеров
procedure TMainForm.MenuItem19Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  if MessageDlg(SConfirmDeletion, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    DockerCmd := 'docker container prune -f';
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
begin
  if InputQuery(SRunImage, SRunImageCommand, RunImageCmd) then
    //Внутренняя или внешняя команда?
  begin
    if Pos('-', RunImageCmd) <> 0 then
      DockerCmd := Trim('docker run ' + RunImageCmd + ' ' + ImageTag)
    else
      DockerCmd := Trim('docker run ' + ImageTag + ' ' + Trim(RunImageCmd));

    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Форма Dockerfile
procedure TMainForm.MenuItem20Click(Sender: TObject);
begin
  if (ImageBox.Count <> 2) and (ImageBox.SelCount <> 0) and
    (ImageBox.ItemIndex <> 0) and (ImageBox.ItemIndex <> ImageBox.Count - 1) then
    DFileForm.Caption := ImageTag
  else
    DFileForm.Caption := SDockerHub;

  DFileForm.Show;
end;

//Стоп выбранного контейнера
procedure TMainForm.MenuItem21Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  DockerCmd := 'docker stop ' + ContainerName;
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Стоп всех контейнеров
procedure TMainForm.MenuItem22Click(Sender: TObject);
var
  i: integer;
  S: string;
  FStartDockerCommand: TThread;
begin
  S := '';
  for i := 1 to ContainerBox.Count - 2 do
    S := S + ' ' + Copy(ContainerBox.Items[i], 1, Pos(' ', ContainerBox.Items[i]) - 1);

  DockerCmd := 'docker stop ' + S;
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Import the contents from a tarball to create a filesystem image
procedure TMainForm.MenuItem23Click(Sender: TObject);
var
  S: string;
  FStartDockerCommand: TThread;
begin
  if OpenDialog1.Execute then
  begin
    S := 'my-new:image';
    repeat
      if not InputQuery(SImportTarFile, SPullString, S) then
        Exit
    until S <> '';
    DockerCmd := 'docker import "' + OpenDialog1.FileName + '" ' + Trim(S);
    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Export a container’s filesystem as a tar archive
procedure TMainForm.MenuItem24Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  if SaveDialog1.Execute then
  begin
    DockerCmd := Trim('docker export --output="' + SaveDialog1.FileName +
      '" ' + ContainerName);

    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Rename this Container
procedure TMainForm.MenuItem25Click(Sender: TObject);
var
  S: string;
  FStartDockerCommand: TThread;
begin
  S := ContainerName;
  repeat
    if not InputQuery(SRenameCaption, SRenameString, S) then
      Exit
  until S <> '';

  DockerCmd := 'docker rename ' + ContainerName + ' ' + Trim(S);

  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Rename this Image
procedure TMainForm.MenuItem26Click(Sender: TObject);
var
  S: string;
  FStartDockerCommand: TThread;
begin
  S := ImageTag;
  repeat
    if not InputQuery(SRenameCaption, SRenameString, S) then
      Exit
  until S <> '';

  DockerCmd := 'docker image tag ' + ImageTag + ' ' + Trim(S) +
    ' && docker rmi ' + ImageTag;

  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

procedure TMainForm.MenuItem28Click(Sender: TObject);
begin
  LoginForm.Show;
end;

//Push Image to DockerHub
procedure TMainForm.MenuItem29Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  DockerCmd := Trim('docker push ' + ImageTag);
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Старт контейнера с параметрами
procedure TMainForm.MenuItem3Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  DockerCmd := Trim('docker start ' + ContainerName);
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Войти в Shell запущенного контейнера
procedure TMainForm.MenuItem6Click(Sender: TObject);
var
  FStartTerminal: TThread;
begin
  DockerCmd := '[[ $(docker ps | grep ' + ContainerName + ') ]] || docker start ' +
    ContainerName + '&& sakura -c 120 -r 40 -f 10 -x "docker exec -it ' +
    ContainerName + ' /bin/bash"';
  FStartTerminal := TerminalTRD.Create(False);
  FStartTerminal.Priority := tpNormal;
end;

//Получение Docker-Image
procedure TMainForm.MenuItem7Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  repeat
    if not InputQuery(SPullCaption, SPullString, ImageName) then
      Exit
  until ImageName <> '';

  DockerCmd := 'docker pull ' + Trim(ImageName);
  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Старт Docker-Image с командой --rm
procedure TMainForm.MenuItem8Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  if InputQuery(SRunImageRm, SRunImageCommand, RunImageCmd) then
    //Внутренняя или внешняя команда?
  begin
    if Pos('-', RunImageCmd) <> 0 then
      DockerCmd := Trim('docker run --rm ' + Trim(RunImageCmd) + ' ' + ImageTag)
    else
      DockerCmd := Trim('docker run --rm ' + ImageTag + ' ' + Trim(RunImageCmd));

    FStartDockerCommand := StartDockerCommand.Create(False);
    FStartDockerCommand.Priority := tpNormal;
  end;
end;

//Запуск образа и вход в BASH
procedure TMainForm.MenuItem9Click(Sender: TObject);
var
  FStartTerminal: TThread;
begin
  DockerCmd := 'sakura -c 120 -r 40 -f 10 -x "docker run -it ' +
    ImageTag + ' /bin/bash"';
  FStartTerminal := TerminalTRD.Create(False);
  FStartTerminal.Priority := tpNormal;
end;

//Меню образов
procedure TMainForm.PopupMenu1Popup(Sender: TObject);
begin
  ImageMenuControl;
end;

//Меню контейнеров
procedure TMainForm.PopupMenu2Popup(Sender: TObject);
begin
  ContainerMenuControl;
end;

end.
