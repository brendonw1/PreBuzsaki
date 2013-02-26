function [onsmov,movindex] = selectmoviefrommovinfo(movinfo,interact)
%for a movie where there was an upstate somewhere and an interacting stim
%(though maybe not in all of the three sub-movies)

onsmov = [];
movindex = [];

if ~interact%if no interaction
    if movinfo.UpYN1%if movie 1 had an UP
        onsmov = movinfo.Ons1(movinfo.Up.UpFrames1,:);%take the up period in movie 1
        movindex = 1;
    elseif movinfo.UpYN2%if no UP in movie 1, but UP in movie 2
        onsmov = movinfo.Ons2(movinfo.Up.UpFrames2,:);%take the up period in movie 2
        movindex = 1;
    elseif movinfo.UpYN3%if no UP in movie 1 or 2, but UP in movie 3
        onsmov = movinfo.Ons3(movinfo.Up.UpFrames3,:);%take the up period in movie 3
        movindex = 1;
    end
elseif interact
    movinteract = movinfo.Movie1AnyInteract;
    if isempty(movinteract);movinteract = 0;end 
    if movinfo.UpYN1 && movinteract%if movie showed an upstate and had interaction
        ufs1 = movinfo.Up.UpFrames1;
        inter1 = movinfo.Movie1InteractFrame;
        ai1 = sum(ufs1>=inter1);
        di1 = sum(ufs1==inter1);
        bi1 = sum(ufs1<=inter1);
        idx1 = di1 * bi1 * ai1;
        %generate an distribution index for each movie...
        %Something like #before frames x #afterframes, but modulated by
        %whether there is a during-frame
    else
        idx1 = 0;
    end
    
    movinteract = movinfo.Movie2AnyInteract;
    if isempty(movinteract);movinteract = 0;end 
    if movinfo.UpYN2 && movinteract
        ufs2 = movinfo.Up.UpFrames2;
        inter2 = movinfo.Movie1InteractFrame;
        ai2 = sum(ufs2>=inter2);
        di2 = sum(ufs2==inter2);
        bi2 = sum(ufs2<=inter2);
        idx2 = di2 * bi2 * ai2;
    else
        idx2 = 0;
    end
    
    movinteract = movinfo.Movie3AnyInteract;
    if isempty(movinteract);movinteract = 0;end 
    if movinfo.UpYN3 && movinteract
        ufs3 = movinfo.Up.UpFrames3;
        inter3 = movinfo.Movie3InteractFrame;
        ai3 = sum(ufs3>=inter3);
        di3 = sum(ufs3==inter3);
        bi3 = sum(ufs3<=inter3);
        idx3 = di3 * bi3 * ai3;
    else
        idx3 = 0;
    end

    [trash,movindex] = max([idx1 idx2 idx3]);
    eval(['onsmov = movinfo.Ons',num2str(movindex),'(ufs',num2str(movindex),',:);'])
end
