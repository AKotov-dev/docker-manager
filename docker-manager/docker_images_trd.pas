unit docker_images_trd;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, ComCtrls, Forms;

type
  DImages = class(TThread)
  private

    { Private declarations }
  protected
  var
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
    //Sort 0..9 + a, b, c, d, e, f = "IMAGE ID" всегда сверху (третий столбец) - от перескакивания позиций
    ExProcess.Parameters.Add('docker images | sort -rik3; echo "^^^"');

    while not Terminated do
    begin
      //Вывод Images
      ImageList.Clear;
      ExProcess.Execute;

      ImageList.LoadFromStream(ExProcess.Output);
      // ImageList.Text := Trim(ImageList.Text);

      if ImageList.Count <> 0 then
        Synchronize(@Show);

      Sleep(600);
    end;

  finally
    ImageList.Free;
    ExProcess.Free;
    Terminate;
  end;
end;

procedure DImages.Show;
begin
  with MainForm do
  begin
    if ImageBox.ItemIndex = -1 then
      ImageBox.ItemIndex := 0;

    //Обновление с удержанием индекса в списке (образы)
    index := ImageBox.ItemIndex;
    if ImageBox.Items.Text <> ImageList.Text then
    begin
      Application.ProcessMessages;
      ImageBox.Items.Assign(ImageList);
      Application.ProcessMessages;
    end;
    if index < ImageBox.Count then ImageBox.ItemIndex := index;
  end;
end;

end.
