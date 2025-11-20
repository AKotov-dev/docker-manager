unit terminal_trd;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, ComCtrls;

type
  TTerminalTRD = class(TThread)
  private
    FCmd: string;
  protected
    procedure Execute; override;
  public
    constructor Create(const Cmd: string);
  end;

implementation

uses Unit1;

constructor TTerminalTRD.Create(const Cmd: string);
begin
  inherited Create(False);
  // поток создаётся и сразу запускается
  FreeOnTerminate := True; // самоуничтожение
  FCmd := Cmd;
end;

procedure TTerminalTRD.Execute;
var
  ExProcess: TProcess;
begin
  try
    ExProcess := TProcess.Create(nil);
    try
      ExProcess.Executable := 'bash';
      ExProcess.Parameters.Add('-c');
      ExProcess.Parameters.Add(FCmd);
      ExProcess.Options := [poUsePipes];
      // при необходимости можно добавить poWaitOnExit

      ExProcess.Execute;

    finally
      ExProcess.Free;
    end;


  finally
    Terminate;
  end;
end;

end.
