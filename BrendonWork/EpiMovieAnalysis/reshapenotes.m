function movienotes=reshapenotes(notes,keepers);

deletes=1:length(notes.moviename);
deletes(keepers)=[];

movienotes=notes;

movienotes.moviename(deletes)=[];
movienotes.abfname(deletes)=[];
movienotes.stimprotocol(deletes)=[];
movienotes.stimnum(deletes)=[];
movienotes.stimfreq(deletes)=[];
movienotes.stimamp(deletes)=[];
movienotes.timesincelast(deletes)=[];
movienotes.otherdescrip(deletes)=[];
movienotes.observation(deletes)=[];