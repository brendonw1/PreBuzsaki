if isrec
    button = questdlg('Play again?','Game Over','Yes','No','Yes');
else
    button = questdlg({['Game over. Your score is ' num2str(score) '.'],'Play again?'},'Game Over','Yes','No','Yes');
end

if strcmp(button,'Yes')
    delete(gcf)
    clear;
    tetris;
else
    delete(gcf)
    clear
end