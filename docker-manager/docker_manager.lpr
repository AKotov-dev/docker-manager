program docker_manager;

{$mode objfpc}{$H+}

uses
  cthreads,
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  docker_images_trd,
  start_docker_command,
  docker_containers_trd, terminal_trd, 
dockerfile_unit, project_files, login_unit { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title:='DockerManager v1.8';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDFileForm, DFileForm);
  Application.CreateForm(TFilesForm, FilesForm);
  Application.CreateForm(TLoginForm, LoginForm);
  Application.Run;
end.
