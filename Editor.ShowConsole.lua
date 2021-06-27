--
-- This macro emulates Midnight Commander Editor Ctrl+O shortcut.
-- 
-- When pressed out of Editor it opens the Console, so you can enter any command.
-- To return back to the Editor, press Ctrl+O again
--
-- @author: buniak_a_h
-- @url: https://forum.farmanager.com/viewtopic.php?f=15&t=12501
--

local Info = package.loaded.regscript or function(...) return ... end
local nfo = Info {_filename or ...,
  name        = "EditorToCmdLine";
  description = "BAX: Переключение на область Shell с погашенными панелями для доступа к командной строке";
  version     = "1.0.2"; --http://semver.org/lang/ru/
  author      = "BAX";
  url         = [[https://forum.farmanager.com/viewtopic.php?f=15&t=12501]];
  id          = "97C4C4E9-E729-466A-B8EC-F3B836C608A4";
  idea        = 'ujos (https://forum.farmanager.com/memberlist.php?mode=viewprofile&u=14042)';
  history     = [[
1.0.1 от 26.06.2021: стартовая версия
1.0.2 от 27.06.2021: восстановлена реакция на закрытие редактора
]];
  --parent_id   = "";
  --minfarversion = {3,0,0,4744,0};
  --files       = "*.cfg;*.ru.lng";
  --config      = function(nfo,name) end;
  help        = function(nfo,name)
   far.Message(
'    Макрос работает в немодальном редакторе. По Ctrl+O не просто показывает экран консоли, ' ..
'а переключает в среду панелей и гасит последние. Это даёт возможность вводить команды ' ..
'в командную строку.\n\n' ..
'    Возврат в редактор осуществляется по повторному Ctrl+O или по Esc.\n\n' ..
'    Если в исходном редакторе есть отмеченный текст, то по клавише Ctrl+V отмеченный текст '..
'вставляется в командную строку.', 'EditorToCmdLine', nil, 'l'
   )
  end;
  --execute     = function(nfo,name) end;

  --disabled    = false;
  --options     = {};
}
if not nfo then return end
--local O = nfo.options

local F = far.Flags
local EdiStack = {}
----------------- Переключение на панели ------------------
Macro{
  id="FD02076B-828F-475A-A19E-95B99199DE5D";
  area="Editor";
  key="CtrlO";
  description="Командная строка в редакторе по Ctrl+O";
  flags="";
  condition = function(key, data)
   return not next(EdiStack) and band(far.AdvControl(F.ACTL_GETWINDOWINFO).Flags, F.WIF_MODAL) == 0
  end;
  action=function(data)
   local wi = far.AdvControl(F.ACTL_GETWINDOWINFO)
   EdiStack[#EdiStack+1] = {Type=wi.Type; Id=wi.Id}
   for i=1,far.AdvControl(F.ACTL_GETWINDOWCOUNT) do
    wi = far.AdvControl(F.ACTL_GETWINDOWINFO, i)
    if wi.Type == F.WTYPE_PANELS then
     far.AdvControl(F.ACTL_SETCURRENTWINDOW, wi.Pos)
     EdiStack[#EdiStack].NeedOnOff = APanel.Visible or PPanel.Visible
     if EdiStack[#EdiStack].NeedOnOff then Keys"CtrlO" end
     return
    end
   end
  end;
}
------------------ Восстановление в редактор ------------------
local function RestEdit()
  -- 1. Восстановление видимости панелей
  if EdiStack[#EdiStack].NeedOnOff then Keys"CtrlO" end
  -- 2. Возврат к редактору
  local wi
  for i=1,far.AdvControl(F.ACTL_GETWINDOWCOUNT) do
   wi = far.AdvControl(F.ACTL_GETWINDOWINFO, i)
   if wi.Type == EdiStack[#EdiStack].Type and
      wi.Id == EdiStack[#EdiStack].Id then
    far.AdvControl(F.ACTL_SETCURRENTWINDOW, wi.Pos)
    break
   end
  end
  table.remove(EdiStack)
end -- RestEdit
Macro{
  id="4AF3D4C8-5A89-40ED-8407-F7EBFAA3C416";
  area="Shell";
  key="CtrlO";
  description="Восстановление редактора по CtrlO";
  condition=function(key, data) return not not next(EdiStack) end;
  action=function(data)
   RestEdit()
  end;
}
---------------------
Macro{
  id="379D0E92-9830-4C03-A22D-483CCD042C36";
  area="Shell";
  key="Esc";
  description="Восстановление редактора по Esc";
  flags="EmptyCommandLine";
  priority = 99;
  condition=function(key, data) return not not next(EdiStack) end;
  action=function(data)
   RestEdit()
  end;
}
----------------- Обработка закрытия редактора --------------------------
Event {
  id = "AA556FB4-5DF7-42D4-8CD6-DD177A725A7F";
  group       = "EditorEvent";
  description = "Закрытие редактора";
  condition = function(EditorID, Event, Param)
   return Event==F.EE_CLOSE
  end;
  action      = function(EditorID, Event, Param)
   for i,v in ipairs(EdiStack) do
    if v.Type == F.WTYPE_EDITOR and
       v.Id == EditorID then
     table.remove(EdiStack, i)
     break
    end
   end
  end;
}
------------- Вставка отмеченного в комстроку -------------
-- Функция получения строки отмеченного
local function GetSel(EdId)
 local aSel = editor.GetSelection(EdId)
 if not aSel then return end
 if aSel.BlockType == F.BTYPE_COLUMN then
  local asSel = {}
  for i=aSel.StartLine, aSel.EndLine do
   asSel[#asSel+1] = editor.GetString(EdId, i, 3):sub(aSel.StartPos, aSel.EndPos)
  end
  return table.concat(asSel, '\n') .. '\n'
 elseif aSel.BlockType == F.BTYPE_STREAM then
  if aSel.EndLine == aSel.StartLine then
   return editor.GetString(EdId, aSel.StartLine, 3):sub(aSel.StartPos, aSel.EndPos)
  else
   local asSel = {editor.GetString(EdId, aSel.StartLine, 3):sub(aSel.StartPos)}
   for i=aSel.StartLine+1, aSel.EndLine-1 do
    asSel[#asSel+1] = editor.GetString(EdId, i, 3)
   end
   asSel[#asSel+1] =  editor.GetString(EdId, aSel.EndLine, 3):sub(1,aSel.EndPos)
   return table.concat(asSel, '\n')
  end
 else return
 end
end -- GetSel

Macro{
  id="5D5C23EA-097D-4416-A8F6-B448AD491111";
  area="Shell";
  key="AltC";
  description="Вставка отмеченного из редактора в комстроку";
  flags="";
  condition=function(key, data)
   if next(EdiStack) then
    local SelStr = GetSel(EdiStack[#EdiStack].Id)
    if SelStr then
     data.SelStr = SelStr
     return true
    end
   end
  end;
  action=function(data)
   print(data.SelStr)
  end;
}
