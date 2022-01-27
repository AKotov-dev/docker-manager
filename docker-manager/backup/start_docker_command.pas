unit start_docker_command;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, ComCtrls, Forms;

type
  StartDockerCommand = class(TThread)
  private

    { Private declarations }
  protected
  var
    Result: TStringList;

    procedure Execute; override;

    procedure ShowLog;
    procedure StartProgress;
    procedure StopProgress;

  end;

implementation

uses Unit1;

{ TRD }

procedure StartDockerCommand.Execute;
var
  ExProcess: TProcess;
begin
  try //Вывод лога и прогресса
    Synchronize(@StartProgress);

    FreeOnTerminate := True; //Уничтожить по завершении
    Result := TStringList.Create;

    //Рабочий процесс
    ExProcess := TProcess.Create(nil);

    ExProcess.Executable := 'bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(DockerCmd);

    ExProcess.Options := [poUsePipes, poStderrToOutPut];
    //, poWaitOnExit (синхронный вывод)

    ExProcess.Execute;

    //Выводим лог динамически
    while ExProcess.Running do
    begin
      Result.LoadFromStream(ExProcess.Output);

      //Выводим лог
      Result.Text := Trim(Result.Text);

      if Result.Count <> 0 then
        Synchronize(@ShowLog);
    end;

  finally
    Synchronize(@StopProgress);
    Result.Free;
    ExProcess.Free;
    Terminate;
    //Для взаимного исключения выполнения команд и отображения списков Images/Containers
    DockerCmd := '';
  end;
end;

{ БЛОК ОТОБРАЖЕНИЯ ЛОГА }

//Старт индикатора
procedure StartDockerCommand.StartProgress;
begin
  with MainForm do
  begin
    LogMemo.Clear;
    ProgressBar1.Style := pbstMarquee;
    ProgressBar1.Refresh;
  end;
end;

//Стоп индикатора
procedure StartDockerCommand.StopProgress;
begin
  with MainForm do
  begin
    //Вывод информации о контейнере сначала
    if Pos('docker inspect', DockerCmd) <> 0 then
    begin
      LogMemo.SelStart := 0;
      LogMemo.SelLength := 0;
    end;
    Application.ProcessMessages;
    ProgressBar1.Style := pbstNormal;
    ProgressBar1.Refresh;
  end;
end;

//Вывод лога
procedure StartDockerCommand.ShowLog;
var
  i: integer;
begin
  //Вывод построчно
  for i := 0 to Result.Count - 1 do
    MainForm.LogMemo.Lines.Append(Result[i]);

  //Вывод пачками
  //MainForm.LogMemo.Lines.Assign(Result);
end;

end.

