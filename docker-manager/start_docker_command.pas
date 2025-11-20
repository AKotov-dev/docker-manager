unit start_docker_command;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, ComCtrls, Forms;

type
  TStartDockerCommand = class(TThread)
  private
    FCmd: string;            // локальная команда для потока
    FResult: TStringList;
  protected
    procedure Execute; override;
    procedure ShowLog;
    procedure StartProgress;
    procedure StopProgress;
  public
    constructor Create(const Cmd: string);
  end;

implementation

uses Unit1;

{ ======= CONSTRUCTOR ======= }
constructor TStartDockerCommand.Create(const Cmd: string);
begin
  inherited Create(False);  // поток создаётся и запускается
  FreeOnTerminate := True;
  FCmd := Cmd;
  FResult := TStringList.Create;
end;

{ ======= EXECUTE ======= }
procedure TStartDockerCommand.Execute;
var
  ExProcess: TProcess;
begin
  try
    Synchronize(@StartProgress);

    ExProcess := TProcess.Create(nil);
    try
      ExProcess.Executable := 'bash';
      ExProcess.Parameters.Add('-c');
      ExProcess.Parameters.Add(FCmd);
      ExProcess.Options := [poUsePipes, poStderrToOutPut];

      ExProcess.Execute;

      while ExProcess.Running do
      begin
        FResult.LoadFromStream(ExProcess.Output);
        FResult.Text := Trim(FResult.Text);
        if FResult.Count <> 0 then
          Synchronize(@ShowLog);
      end;

    finally
      ExProcess.Free;
    end;

  finally
    Synchronize(@StopProgress);
    FResult.Free;
  end;
end;

{ ======= ЛОГИ ======= }
procedure TStartDockerCommand.StartProgress;
begin
  with MainForm do
  begin
    LogMemo.Clear;
    Application.ProcessMessages;
    ProgressBar1.Style := pbstMarquee;
    ProgressBar1.Refresh;
  end;
end;

procedure TStartDockerCommand.StopProgress;
begin
  with MainForm do
  begin
    // Вывод информации о контейнере сначала
    if Pos('docker inspect', FCmd) <> 0 then
    begin
      LogMemo.SelStart := 0;
      LogMemo.SelLength := 0;
    end;

    Application.ProcessMessages;
    ProgressBar1.Style := pbstNormal;
    ProgressBar1.Refresh;
  end;
end;

procedure TStartDockerCommand.ShowLog;
var
  i: integer;
begin
  for i := 0 to FResult.Count - 1 do
    MainForm.LogMemo.Lines.Append(FResult[i]);
end;

end.
