%Confirms quitting

button = questdlg('Quit without saving?','Confirm Exit','Yes','No','No');
if strcmp(button,'Yes')
   delete(gcf);
end