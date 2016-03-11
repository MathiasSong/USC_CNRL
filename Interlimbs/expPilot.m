% Motor learning project 2015
% Youngmin Oh & Kangwoo Lee
% Updated: 8/18/2015
% Schedule is changed (with baseline and more washout)
% schedule: 1=Feedback, 4=Localization1, 5=Localization2, 6=Rest, 7=rest2
% usage: expPilot('taskBase',99999)

function expPilot(schedule,subjID,Gr)
load(schedule)
cgloadlib % Cogent library load
cgopen(3,0,0,1) % 1280x1024

%% text feedback
% Convert bmp files to id, and make it easier to call
cgloadbmp(2,'tooslow.bmp',348,75)
cgloadbmp(3,'toofast.bmp',305,74)
cgloadbmp(16,'ready.bmp',691,102)
cgloadbmp(11,'instruction_strategy.bmp',800,240)
cgloadbmp(10,'instruction_stop.bmp',800,240)

%% experiment parameters
rcursor = 4; % radius of the cursor (pixels)
rstart = 10; % radius of the start circle (pixels)
rarc = 200; % radius of the arc (pixels)
rtargetin = 6; % radius of the inner circle target (pixels)
actwidth = 4; % actual target width for success (degs), originally 3
rtargetout = rarc*actwidth*pi/180; % radius of the outer circle target (pixels)
rptargetout=rtargetout*0.7; % radius of inner circle of proper target
tharc = 1; % thickness of the arc (pixels)
halfarc = 270; % half-angle of the arc (degs), originally 340
tlow = 50; % movement time lower bound (ms) originally 100
tup= 300; % movement time upper bound (ms) originally 300
calxy = [1.28 1]; % scales of x and y
scx = 0; % center of starting point x (pixels)
scy = -128; % center of starting point y (pixels), originally 256
Tar_disp=1; % Target will be disappeared after strategy instruction


%% sound definition
matsound = sinwav(760,0.05,20000);
matsound2 = sinwav(760,0.1,48000);
matsound3 = sinwav(760,0.05,34000);
cgsound('open');
cgsound('matrixSND',8,matsound3,12000);
cgsound('matrixSND',9,matsound,12000);
cgsound('matrixSND',10,matsound2,12000);

%% waiting for start
cgfont('Arial',65)
kd(2) = 0;
while ~kd(2) % key 1: start
    cgpencol(1,1,1)
    cgdrawsprite(16,0,-100) % cgbmp_key, x,y
    [kd,kp] = cgkeymap;
    cgflip(0,0,0);
end

%% variable definition and initial values
phase = 0; % phase controls each stage within a single trial
time0 = time;
trial = 1;
hx = 0; hy = 0; % hand position
vx = 0; vy = 0; % visual cursor position
x=0;
timepass = 0;
soundplayed = 0;
soundalarmed = 0;
initstart = 1;
lineangle=90; % initial angle of localization

hand_theta = zeros(1,length(taskschedule)); % hand angle (degs)
cursor_theta = zeros(1,length(taskschedule)); % cursor angle (degs)
%angle_clamped = zeros(1,length(taskschedule)); % clamped feedback location
reaction_time = zeros(1,length(taskschedule)); % from onset of target to move out of start circle
movement_time = zeros(1,length(taskschedule)); % from move out of start circle to cross arc
kinematic_data = []; % kinematic data during shooting
data.kinematic_data = [];
cgpenwid(1) % cursor width
cgfont('Arial',16)

%% main loop
while trial <= length(taskschedule)  % one loop corresponds to one mouse reading
    [kd,kp] = cgkeymap;
    if kd(88) % F12 = exit button
        cgsound('shut')
        cgshut
    end
    %% input and output
    % draw the start circle
    cgpencol(1,1,1)
    cgellipse(scx,scy,2*rstart,2*rstart) 
    % Trial number (not shown to subject)
    cgtext(sprintf('%d',trial),-600,-500)
    
    % record last point
    lastvx = vx;
    lastvy = vy;
    lasthx = hx;
    lasthy = hy;
    lastime = timepass;
    lastx=x;
    
    % get a new input
    [x,y,bs,bp] = cgmouse; % read mouse input
    hx = calxy(1)*x - scx; % calibrated hand position
    hy = calxy(2)*y - scy;
    timepass = time; % time at mouse input
    
    % visuomotor rotation
    rangle = rotationangle(trial) + reachnoise(trial);
    Rot_mat=[cos(rangle*pi/180) -sin(rangle*pi/180); sin(rangle*pi/180) cos(rangle*pi/180)]; % Rotation matrix
    vxy = Rot_mat*[hx;hy]; % rotation around the center
    vx = vxy(1);
    vy = vxy(2);
    svx = (vx + scx); % screen coordinate (mirror image)
    svy = vy + scy;
    r = sqrt(vx^2+vy^2);
    
    %% stages at each trial
    switch phase
        %-----------------------------------------------------------------------------------------
        % phase 0: waiting for start signal (target appearance)
        case 0
            switch taskschedule(trial)   
                case 4 % Localization 1
                    displaymessage('Wait')
                    % cursor
                    cgpencol(1,0,0) 
                    cgellipse(-(hx+scx),hy+scy,2*rcursor,2*rcursor,'f')
                    % Waiting time, give 2sec more for localization
                    timewait = iti(trial);
                    timewait=timewait+2000;
                    
                    if r > rstart % check early start
                        phase = 3;
                        validstart = 0;
                    elseif timepass - time0 >= timewait
                        phase = 1;
                        time1 = timepass;
                        validstart = 1;
                    end
                case 5 % Localization 2
                    % Waiting time
                    timewait=0;

                    if r > rstart % check early start
                        phase = 3;
                        validstart = 0;
                    elseif timepass - time0 >= timewait
                        phase = 1;
                        time1 = timepass;
                        validstart = 1;
                    end
                    if rem(round(rand),2)==0 
                        lineangle=0;
                    else
                        lineangle=180;
                    end
                case 6 % Break & start using strategy instruction
                    cgdrawsprite(11,0,-100)
                    instruction_time=20000; % Reading time for instruction
                    Tar_disp=0; % From now, target will be disappeared
                    if timepass-time0 > instruction_time
                        phase = 0;
                        time0 = timepass;
                        soundplayed = 0;
                        soundalarmed = 0;
                        trial = trial + 1;
                    end
                case 7 % Break & stop using strategy instruction
                    cgdrawsprite(10,0,-100)
                    instruction_time=20000; % Reading time for instruction
                    Tar_disp=1; % From now, target will be shown
                    if timepass-time0 > instruction_time
                        phase = 0;
                        time0 = timepass;
                        soundplayed = 0;
                        soundalarmed = 0;
                        trial = trial + 1;
                    end
                otherwise
                    % Cursor
                    cgpencol(1,0,0)
                    cgellipse(-(hx+scx),hy+scy,2*rcursor,2*rcursor,'f')
                    timewait = iti(trial);
                    if r > rstart % check early start
                        phase = 3;
                        validstart = 0;
                    elseif timepass - time0 >= timewait
                        phase = 1;
                        time1 = timepass;
                        validstart = 1;
                    end
            end
   
            %-------------------------------------------------------------------------------------
            % phase 1: target appears and shoot
        case 1
            fb_shown=0; % Feedback shown flag. It will be changed in phase 2
            if soundplayed==0
                cgsound('play',9)
                soundplayed = 1;
            end
            switch taskschedule(trial)
                case 0              
                    cgpencol(1,0,0)
                    cgellipse(svx,svy,2*rcursor,2*rcursor,'f')
                    local=0; % target hidden flag
                case 1
                    cgpencol(1,0,0)
                    cgellipse(svx,svy,2*rcursor,2*rcursor,'f')
                    local=0; % target hidden flag
                case 4
                    local=1; % target hidden flag
                    displaymessage('Shoot')
                    % cursor only at the beginning
                    if r<rstart
                        cgpencol(1,0,0)
                        cgellipse(svx,svy,2*rcursor,2*rcursor,'f')
                    end
                case 5
                    displaymessage('Estimate')
                    cgpencol(1,0,0)
                    if x~=lastx
                        dx = x - lastx;
                        lineangle = lineangle - 0.2*dx;
                    end
                    
                    % Reach the edge of the arc. (This needs to be manually
                    % changed if the arc size is changed.)
                    if lineangle < 0
                        lineangle = 0;
                    elseif lineangle >180
                        lineangle = 180;
                    end
                    
                    slnx = rarc*cos(pi*(180-lineangle)/180) + scx;
                    slny = rarc*sin(pi*(180-lineangle)/180) + scy;
                    
                    cgdraw(scx,scy,slnx,slny)
                    cgellipse(slnx,slny,4*rcursor,4*rcursor,'f')
                    % detect mouse click 
                    if bp==4  
                        hand_theta(trial) = lineangle;
                        hand_xy(:,trial) = [slnx; slny]; % Remove this if causing a bug
                        time3 = timepass;
                        net_time(trial) = time3 - time1;
                        phase = 2;
                        cgsound('play',9)
                        soundplayed = 1;
                        time3 = time;
                    else
                        time3 = timepass;
                    end
                    local=1; % target hidden flag
                case 6
                    local=0; % target hidden flag
                case 7
                    local=0;
                otherwise
                    local=0; % target hidden flag
            end
                
            % Reaction time calculation
            if r <= rstart
            elseif r > rstart && initstart == 1
                reaction_time(trial) = timepass - time1; % time from onset of target to move out of start circle
                initstart = 0;
                time15 = timepass;
            end        
            % Draw targets
            draw_target(trial,scx,scy,rarc,rtargetin,rtargetout,rptargetout,targetlocation,local,r,Gr,fb_shown,Tar_disp);
            
            % algorithm to detect crossing and to calculate interpolation point
            % (For hand crossing point)
            if sqrt(hx^2+hy^2)>=rarc && sqrt(lasthx^2+lasthy^2)<=rarc
               a = (hy-lasthy)/(hx-lasthx); % slope
               b = lasthy - lasthx*(hy-lasthy)/(hx-lasthx); % y-intercept
               if hx==lasthx
                   arcx = hx;
                   arcy = sign(hy)*sqrt(rarc^2-arcx^2);
               elseif hy==lasthy
                   arcy = hy;
                   arcx = sign(hx)*sqrt(rarc^2-arcy^2);
               else
                   if hy > 0
                       arcy = (b + sqrt(a^2*(a^2+1)*rarc^2-a^2*b^2)) / (a^2+1);
                       arcx = (arcy-b)/a;
                   elseif hy < 0
                       arcy = (b - sqrt(a^2*(a^2+1)*rarc^2-a^2*b^2)) / (a^2+1); 
                       arcx = (arcy-b)/a;
               
                   end
               end
               hand_xy(:,trial) = [arcx; arcy];
               
               if arcy > 0
                   hand_theta(trial) = (180/pi)*acos(arcx/sqrt(arcx^2+arcy^2));
               else
                   hand_theta(trial) = -(180/pi)*acos(arcx/sqrt(arcx^2+arcy^2));
               end
                
                %hand_theta(trial) = cursor_theta(trial) - rangle;
                d1 = sqrt((arcx-lasthx)^2+(arcy-lasthy)^2);
                d2 = sqrt((arcx-hx)^2+(arcy-hy)^2);
                time2 = (d2*timepass+d1*lastime)/(d1+d2);
                if taskschedule(trial)==5
                    movement_time(trial) = time3 - time15;
                else
                    movement_time(trial) = time2 - time15;
                end
                % change phase by mouse click, not crossing estimation
                if taskschedule(trial) ~= 5 
                    phase = 2;
                end
            end
            if r>rarc && taskschedule(trial)==4
                cgsound('play',9)
                soundplayed = 1;
            end
            kinematic_data = [kinematic_data; trial timepass hx hy]; % important for Joomyung
            %-----------------------------------------------------------------------------------------
            % phase 2: provide feedback
        case 2
            % check movement time (Not for localization 2)
            if movement_time(trial)>tup
                if taskschedule(trial)~=5, cgdrawsprite(2,0,-100);end
            elseif movement_time(trial)<tlow
                if taskschedule(trial)~=5, cgdrawsprite(3,0,-100);end
            end
            
            % Draw targets
            draw_target(trial,scx,scy,rarc,rtargetin,rtargetout,rptargetout,targetlocation,local,r,Gr,fb_shown,Tar_disp);

            % feedback
            switch taskschedule(trial)
                case 0 % Baseline
                    cgpencol(1,0,0)
                    cgrect(-(arcx+scx),arcy+scy,4*rcursor,4*rcursor)
                    fb_shown=1; % Feedback shown flag
                    % show feedback 
                    if (timepass - time2 > 2000), phase = 3;end
                case 1 % Adaptation
                    rot_xy=Rot_mat*[arcx;arcy];
                    cgpencol(1,0,0)
                    cgrect(-(rot_xy(1)+scx),rot_xy(2)+scy,4*rcursor,4*rcursor)
                    fb_shown=1; % Feedback shown flag
                    % show feedback 
                    if (timepass - time2 > 2000), phase = 3;end
                case 4 % Localization 1
                    % no feedback
                    if (timepass - time2 > 500), phase = 3;end
                case 5 % Localization 2
                    cgpencol(1,0,0)
                    cgdraw(scx,scy,slnx,slny)
                    cgellipse(slnx,slny,4*rcursor,4*rcursor,'f')
                    % show feedback 
                    if (timepass - time2 > 1000), phase = 3;end
            end
            
            % show feedback for 2000ms
%             if (timepass - time2 > 1000)
%                 phase = 3;
%             elseif timepass - time2 > 2000
%                 phase = 3;
%             end
            
            %-----------------------------------------------------------------------------------------
            % phase 3: guide to return
        case 3
            cgpencol(1,1,1)
            if  r > 2*rstart
                cgpencol(1,0,0)
                cgellipse(scx,scy,2*r,2*r)
            elseif r <= 2*rstart && r > rstart
                cgpencol(1,0,0)
                cgellipse(-(hx+scx),hy+scy,2*rcursor,2*rcursor,'f')
            elseif r <= rstart
                phase = 0;
                time0 = timepass;
                soundplayed = 0;
                soundalarmed = 0;
                initstart = 1;
                if validstart==1
                    trial = trial + 1;
                end
                % save data
                data.hand_theta = hand_theta;
                data.cursor_theta = cursor_theta;
                %data.angle_clamped = angle_clamped;
                data.reaction_time = reaction_time;
                data.movement_time = movement_time;
                data.kinematic_data = [data.kinematic_data; kinematic_data];
                save(sprintf('../Data/subj%d-%s',subjID,schedule),'data');
                kinematic_data = [];
            end
            
    end
    
    cgflip(0,0,0)
    
    
end

expara.rcursor = rcursor;
expara.rstart = rstart;
expara.rarc = rarc;
expara.rtarget = rtargetin;
expara.tharc = tharc;
expara.actwidth = actwidth;
expara.tup = tup;
expara.tlow = tlow;
expara.calxy = calxy;
expara.scx = scx;
expara.scy = scy;

sch.nTask = nTask;
sch.iti = iti;
sch.rotationangle = rotationangle;
sch.targetlocation = targetlocation;
sch.taskschedule = taskschedule;
sch.reachnoise = reachnoise;
%sch.clampnoise = clampnoise;

save(sprintf('Data/subj%d-%s',subjID,schedule),'data','expara','sch');
cgsound('shut')
cgshut


