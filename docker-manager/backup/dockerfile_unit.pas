unit dockerfile_unit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TDFileForm }

  TDFileForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DFileMemo: TMemo;
    procedure BitBtn1Click(Sender: TObject);
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

//Правим исходный образ по сценарию Dockerfile
procedure TDFileForm.BitBtn1Click(Sender: TObject);
var
  FStartDockerCommand: TThread;
begin
  DFileMemo.Lines.SaveToFile(GetUserDir + '.config/DockerManager/Dockerfile');
  DockerCmd := 'cd ~/.config/DockerManager; docker build -t ' + DFileForm.Caption + ' .';

  FStartDockerCommand := StartDockerCommand.Create(False);
  FStartDockerCommand.Priority := tpNormal;
end;

//Восстанавливаем последний созданный Dockerfile
procedure TDFileForm.FormShow(Sender: TObject);
begin
  if FileExists(GetUserDir + '.config/DockerManager/Dockerfile') then
    DFileMemo.Lines.LoadFromFile(GetUserDir + '.config/DockerManager/Dockerfile');

  DFileMemo.Lines[0]:='From ' + DFileForm.Caption;
end;

end.
