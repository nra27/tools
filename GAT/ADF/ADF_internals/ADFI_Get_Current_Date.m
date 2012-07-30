function [D,date] = ADFI_Get_Current_Date(D);
%
% date = ADFI_Get_Current_Date(D)
%
% Returns the current date and time in a blank-filled character array.
%
% date - Current date/time in an array blank-filled to D.Date_Time_Size.
% D - Declaration space

% Get current time
ct = now;

Day = datestr(ct,8);
Month = datestr(ct,3);
Date = datestr(ct,7);
Time = datestr(ct,13);
Year = datestr(ct,10);

date = [Day ' ' Month ' ' Date ' ' Time ' ' Year];
date = ADFI_Blank_Fill_String(date,D.Date_Time_Size);