local F = far.Flags
local EdiStack = {}
----------------- Переключение на панели ------------------
Macro{
  id="FD02076B-828F-475A-A19E-95B99199DE5D";
  area="Editor";
  key="CtrlO";
  description="Командная строка в редакторе по Ctrl+O";
  url=[[https://forum.farmanager.com/viewtopic.php?p=166999#p166999]];
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
Macro{
  id="4AF3D4C8-5A89-40ED-8407-F7EBFAA3C416";
  area="Shell";
  key="CtrlO";
  description="Восстановление редактора по CtrlO";
  condition=function() return not not next(EdiStack) end;
  action=function(data)
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
  end;
}
----------------- Обработка закрытия редактора --------------------------
NoEvent {
  id = "AA556FB4-5DF7-42D4-8CD6-DD177A725A7F";
  group       = "EditorEvent";
  description = "Закрытие редактора";
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
  key="AltV";
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