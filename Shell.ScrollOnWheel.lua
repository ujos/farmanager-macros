--
-- This macro enables user to scroll the console under the pannels with mouse wheel
-- 
-- @author: Dmytro Ovdiienko (ujos)
--

Macro {
  area="Shell"; 
  key="MsWheelUp"; 
  description="Use MsWheel to scroll the buffer"; 
  condition = function() return not(APanel.Visible or PPanel.Visible) end;
  action = function()
    Keys('CtrlAltUp')
  end;
}

Macro {
  area="Shell"; 
  key="MsWheelDown"; 
  description="Use MsWheel to scroll the buffer"; 
  condition = function() return not(APanel.Visible or PPanel.Visible) end;
  action = function()
    Keys('CtrlAltDown')
  end;
}

Macro {
  area="Shell"; 
  key="ShiftMsWheelUp"; 
  description="Use MsWheel to scroll the buffer"; 
  condition = function() return not(APanel.Visible or PPanel.Visible) end;
  action = function()
    Keys('CtrlAltPgUp')
  end;
}

Macro {
  area="Shell"; 
  key="ShiftMsWheelDown"; 
  description="Use MsWheel to scroll the buffer"; 
  condition = function() return not(APanel.Visible or PPanel.Visible) end;
  action = function()
    Keys('CtrlAltPgDown')
  end;
}
