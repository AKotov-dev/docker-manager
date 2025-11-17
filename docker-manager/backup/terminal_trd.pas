unit terminal_trd;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, ComCtrls;

type
  TerminalTRD = class(TThread)
  private

    { Private declarations }
  protected
    procedure Execute; override;

  end;

implementation

uses Unit1;

{ TRD }

procedure TerminalTRD.Execute;
var
  ExProcess: TProcess;
begin
  try
    FreeOnTerminate := True; //Уничтожить по завершении

    //Рабочий процесс
    ExProcess := TProcess.Create(nil);
    ExProcess.Executable := 'bash';
    // ExProcess.Options := [poUsePipes, poWaitOnExit]; //poStderrToOutPut
    ExProcess.Parameters.Add('-c');

    ExProcess.Parameters.Add(DockerCmd);
    ExProcess.Execute;
  finally
    ExProcess.Free;
    Terminate;
  end;

end;

end.
