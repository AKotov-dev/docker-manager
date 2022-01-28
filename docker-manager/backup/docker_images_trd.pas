unit docker_images_trd;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, ComCtrls, Forms, Dialogs;

type
  DImages = class(TThread)
  private

    { Private declarations }
  protected
  var //Строка с кодом кнопки пульта: Key[0]
    ImageList: TStringList;
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
    ImageList := TStringList.Create;

    //Рабочий процесс
    ExProcess := TProcess.Create(nil);
    ExProcess.Executable := 'bash';
    ExProcess.Options := [poUsePipes, poWaitOnExit]; //poStderrToOutPut
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add('docker images; echo "^^^"');

    while not Terminated do
    begin
      //Если параллельно не выполняется команда вывести списки
      Sleep(500);

      //Вывод Images
      ImageList.Clear;
    //  Application.ProcessMessages;
      ExProcess.Execute;

      ImageList.LoadFromStream(ExProcess.Output);
      // ImageList.Text := Trim(ImageList.Text);

      if ImageList.Count <> 0 then
        Synchronize(@Show);
    end;

  finally
    ImageList.Free;
    ExProcess.Free;
    Terminate;
  end;
end;

{ ФИНАЛЬНЫЕ ДЕЙСТВИЯ ПО КОДАМ ИЗ ПОТОКА }

procedure DImages.Show;
begin
  with MainForm do
  begin
    if ImageBox.ItemIndex = -1 then
      ImageBox.ItemIndex := 0;

    //Обновление с удержанием индекса в списке (образы)
    index := ImageBox.ItemIndex;
    Application.ProcessMessages;
    if ImageBox.Items.Text <> ImageList.Text then
      ImageBox.Items.Assign(ImageList);
    Application.ProcessMessages;
    ImageBox.ItemIndex := index;
    ImageBox.Repaint;
  end;
end;

end.
