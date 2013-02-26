function CompareNineOffsetLocksteps(movinfo1,movinfo2)

interact1 = movinfo1.Movie1AnyInteract;
interact2 = movinfo2.Movie1AnyInteract;
if isempty(interact1);interact1 = 0;end
if isempty(interact2);interact2 = 0;end
% cycle through all available movies
for movidx1 = 1:3;
    for movidx2 = 1:3;
        eval(['onsmov1 = movinfo1.Ons',num2str(movidx1),';']);
        eval(['onsmov2 = movinfo2.Ons',num2str(movidx2),';']);
        eval(['interactframe1 = movinfo1.Movie',num2str(movidx1),'InteractFrame;'])
        eval(['interactframe2 = movinfo2.Movie',num2str(movidx2),'InteractFrame;'])
        eval(['ufs1 = movinfo1.Up.UpFrames',num2str(movidx1),';'])
        eval(['ufs2 = movinfo2.Up.UpFrames',num2str(movidx2),';'])
        onsmov1 = onsmov1(ufs1,:);
        onsmov2 = onsmov2(ufs2,:);
        
        if ~isempty(interactframe1)
            uinteractframe1 = find(ufs1 == interactframe1);
        else
            uinteractframe1 = 0;
        end
        if isempty(uinteractframe1)
            uinteractframe1 = 0;
        end

        if ~isempty(interactframe2)
            uinteractframe2 = find(ufs2 == interactframe2);
        else
            uinteractframe2 = 0;
        end
        if isempty(uinteractframe2)
            uinteractframe2 = 0;
        end

        %denom is the total ACTIVATIONS in the SHARED CELLS
%         sharedactivecells = find(logical(sum(onsmov1,1).*sum(onsmov2,1)));
%         nonsharedcells = setdiff(1:size(onsmov1,2),sharedactivecells);
%         onsmov1(:,nonsharedcells) = 0;
%         onsmov2(:,nonsharedcells) = 0;
%         minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);

        [lock1,lock2] = findbestrepeats(onsmov1,onsmov2); %#ok<NASGU>
%         perc = sum(lock1(:))/minavail;

        f = highlightlockstep(movinfo1.Conts,onsmov1,onsmov2,[uinteractframe1 uinteractframe2]);
        if interact1+interact2 == 2;
            set(f,'name',[movinfo1.Name,'&',movinfo2.Name,'.  Interact & Interact'])
        elseif interact1+interact2 == 1;
            set(f,'name',[movinfo1.Name,'&',movinfo2.Name,'.  Interact & NonInteract'])
        elseif interact1+interact2 == 0;
            set(f,'name',[movinfo1.Name,'&',movinfo2.Name,'.  NonInteract & NonInteract'])
        end
    end
end
