unit docker_container_trd;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, ComCtrls, Forms, Dialogs;

type
  DContainer = class(TThread)
  private

    { Private declarations }
  protected
  var
    ContainerList: TStringList;
    index: integer;

    procedure Execute; override;

    procedure Show;

  end;

implementation

uses Unit1;

{ TRD }

procedure dimages.Execute;
var
  ExProcess: TProcess;
begin
  try
    index := 0;
    FreeOnTerminate := True; //Уничтожить по завершении
    ContainerList := TStringList.Create;

    //Рабочий процесс
    ExProcess := TProcess.Create(nil);
    ExProcess.Executable := 'bash';
    ExProcess.Options := [poUsePipes, poWaitOnExit]; //poStderrToOutPut
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add('docker ps -a');

    while not Terminated do
    begin
      //Если параллельно не выполняется команда вывести списки
        Sleep(500);
        //Вывод Containers
        ContainerList.Clear;

        Application.ProcessMessages;
        ExProcess.Execute;

        ContainerList.LoadFromStream(ExProcess.Output);
        ContainerList.Text := Trim(ContainerList.Text);

        if ContainerList.Count <> 0 then
          Synchronize(@Show);
    end;

  finally
    ContainerList.Free;
    ExProcess.Free;
    Terminate;
  end;
end;

{ ФИНАЛЬНЫЕ ДЕЙСТВИЯ ПО КОДАМ ИЗ ПОТОКА }

procedure DContainer.Show;
begin
  with MainForm do
  begin
    //Обновление с удержанием индекса в списке (контейнеры)
    if ContainerBox.ItemIndex = -1 then
      ContainerBox.ItemIndex := 0
    else
      index := ContainerBox.ItemIndex;
    if ContainerBox.Items.Text <> ContainerList.Text then
      ContainerBox.Items.Assign(ContainerList);
    Application.ProcessMessages;
    ContainerBox.ItemIndex := index;
    ContainerBox.Repaint;
  end;
end;

end.

