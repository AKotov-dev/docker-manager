unit docker_containers_trd;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, ComCtrls, Forms, Dialogs;

type
  DContainers = class(TThread)
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

procedure DContainers.Execute;
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
    ExProcess.Parameters.Add('docker ps -a; echo ^^^');

    while not Terminated do
    begin
      //Если параллельно не выполняется команда вывести списки
      Sleep(500);

      //Вывод Containers
      ContainerList.Clear;
      ExProcess.Execute;

      ContainerList.LoadFromStream(ExProcess.Output);
      //   ContainerList.Text := Trim(ContainerList.Text);

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

procedure DContainers.Show;
begin
  with MainForm do
  begin
    if ContainerBox.ItemIndex = -1 then
      ContainerBox.ItemIndex := 0;

    ContainerBox.items.BeginUpdate;

    //Обновление с удержанием индекса в списке (контейнеры)
    index := ContainerBox.ItemIndex;
    if ContainerBox.Items.Text <> ContainerList.Text then
    begin
      Application.ProcessMessages;
      ContainerBox.Items.Assign(ContainerList);
      Application.ProcessMessages;
    end;
    ContainerBox.ItemIndex := index;

    ContainerBox.items.EndUpdate;
  end;
end;

end.
