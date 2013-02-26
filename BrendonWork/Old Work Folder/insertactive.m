function insertactive

oncells=evalin('base','pickedcells');%bring in "oncells" matrix from base workspace

framenumber=evalin('base','framenumber');
movienumber=evalin('base','movienumber');
numb=str2num(get(gco,'tag'));

oncells(framenumber,movienumber,numb)=1;%assign a "1" in the frame and movie where a paricular cell is active 
assignin('base','pickedcells',pickedcells);%call 

numb2=num2str(numb);%display acknowledgement of assignment of active cell
display=strcat('cell #',numb2,' assigned as on');
disp(display)