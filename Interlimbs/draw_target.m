%% genSchedule_sub
% Kangwoo Lee
% 1/6/2016
% This function is a subfunction of expPilot.m.
% It is made only to reduce the lines of expPilot code.

function draw_target(trial,scx,scy,rarc,rtargetin,rtargetout,rptargetout,targetlocation,local,r,Gr,fb_shown,Tar_disp)

% target coordinate
stx = -(rarc*cos(pi*targetlocation(trial)/180) + scx);
sty = rarc*sin(pi*targetlocation(trial)/180) + scy;
cgpencol(1,1,1)
%Tn_angle=22.5+ (0:45:315);
Tn_angle=targetlocation(trial)-45;
snx = -(rarc*cos(pi*Tn_angle/180) + scx);
sny = rarc*sin(pi*Tn_angle/180) + scy;

if local==1
    % Draw half circle for localization
    for i=1:9
        cgpencol(1.0*normpdf(i,5,4),1.0*normpdf(i,5,4),1.0*normpdf(i,5,4))
        %cgellipse(scx,scy,2*(rarc+(i-5)),2*(rarc+(i-5)))
        cgarc(scx,scy,2*(rarc+(i-5)),2*(rarc+(i-5)),0,180)
    end
else
    if Tar_disp==1 % everything shown till strategy instruction
        cgellipse(stx,sty,2*rtargetin,2*rtargetin,'f')
        cgellipse(stx,sty,2*rptargetout,2*rptargetout)
        cgellipse(stx,sty,2*rtargetout,2*rtargetout)
        %cgellipse(snx,sny,2*rtargetout,2*rtargetout)
    else
        switch Gr
        case 1 % two targets shown
            cgellipse(stx,sty,2*rtargetin,2*rtargetin,'f')
            cgellipse(stx,sty,2*rptargetout,2*rptargetout)
            cgellipse(stx,sty,2*rtargetout,2*rtargetout)
            cgellipse(snx,sny,2*rtargetout,2*rtargetout)
        case 2 % two targets shown, disappearing bull's eye 
            if fb_shown==1 || r>(rarc/3)
                cgellipse(snx,sny,2*rtargetout,2*rtargetout)
            else
                cgellipse(snx,sny,2*rtargetout,2*rtargetout)
                cgellipse(stx,sty,2*rtargetin,2*rtargetin,'f')
                cgellipse(stx,sty,2*rptargetout,2*rptargetout)
                cgellipse(stx,sty,2*rtargetout,2*rtargetout) 
            end
        case 3 % two targets shown, disappearing neighboring target
            if fb_shown==1 || r>(rarc/3)
                cgellipse(stx,sty,2*rtargetin,2*rtargetin,'f')
                cgellipse(stx,sty,2*rptargetout,2*rptargetout)
                cgellipse(stx,sty,2*rtargetout,2*rtargetout)
            else
                cgellipse(stx,sty,2*rtargetin,2*rtargetin,'f')
                cgellipse(stx,sty,2*rptargetout,2*rptargetout)
                cgellipse(stx,sty,2*rtargetout,2*rtargetout)
                cgellipse(snx,sny,2*rtargetout,2*rtargetout) 
            end
        case 4 % only bull's eye shown, disappearing bull's eye
            if fb_shown==1 || r>(rarc/3)
            else
               cgellipse(stx,sty,2*rtargetin,2*rtargetin,'f')
               cgellipse(stx,sty,2*rptargetout,2*rptargetout)
               cgellipse(stx,sty,2*rtargetout,2*rtargetout)
               cgellipse(snx,sny,2*rtargetout,2*rtargetout)
            end   
        end        
    end
    
end

end