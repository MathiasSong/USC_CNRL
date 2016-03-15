%% new genSchedule generator
% Youngmin Oh & Kangwoo Lee
% Updated: 8/18/2015
% Schedule is changed (with baseline and more washout)

%% Default variables
clear all; clc;
rng(110); % fix random seed
targetvar_theta = 180; % originally noise, now location of target
nFam_T=60; % nTrial of familiarization
nB_T=40; % nTrial of baseline, 20
nA_T=190; % nTrial of abrupt perturbation
nA2_T=2; % nTrial of perturbation without strategy info
P = 45; % perturbation level
nL_T=10; % Localization trial
nW_T=10; % washout (This case, re-adaptation!!!)
nW2_T=80; % washout at the end

reachvar_thetaControl = 0.5;
save defaultVar.mat

%% Schedule Generator
% taskschedule -> 0=baseline, 1 = feedback,  
% 4= localization1, 5=localization2, 6=control break(start using strategy)
% 7= stop using strategy

% Test trials
% load defaultVar.mat
taskschedule = [zeros(1,2) 6 ones(1,8) 4 5 7 zeros(1,2) ]; 
rotationangle = [zeros(1,2) 0 P*ones(1,8) zeros(1,2) 0 zeros(1,2) ];
% taskschedule = [zeros(1,1) ones(1,1) 1*ones(1,7)]; % alternative schedule
% rotationangle = [zeros(1,1) P*ones(1,1) P*ones(1,7)];

[nTask,iti,targetlocation,reachnoise]=genSchedule_sub...
    (taskschedule,targetvar_theta,reachvar_thetaControl); % call subfunction
save taskTest

% Test trials 2: Baseline + adaptation
taskschedule = [zeros(1,10) 1*ones(1,2) 6 1*ones(1,102)]; 
rotationangle = [zeros(1,10) P*ones(1,2) 0 P*ones(1,102)];
% taskschedule = [zeros(1,10) repmat([4 5],1,nL_T)]; 
% rotationangle = [zeros(1,10) zeros(1,nL_T*2)];
[nTask,iti,targetlocation,reachnoise]=genSchedule_sub...
    (taskschedule,targetvar_theta,reachvar_thetaControl);
save taskTest1

% Sample trials: For explanation
taskschedule = [zeros(1,4)  4 5 4 5 ]; 
rotationangle = [zeros(1,4) zeros(1,4)];
[nTask,iti,targetlocation,reachnoise]=genSchedule_sub...
    (taskschedule,targetvar_theta,reachvar_thetaControl);
save taskSample

% familiarization and baseline for abrupt perturbation
load defaultVar.mat
taskschedule = [0*ones(1,nFam_T) repmat([4 5],1,3*nL_T)];
nTask = length(taskschedule);
rotationangle = [0*ones(1,nFam_T) zeros(1,nL_T*6)];
[nTask,iti,targetlocation,reachnoise]=genSchedule_sub...
    (taskschedule,targetvar_theta,reachvar_thetaControl);
save taskBase

keyboard;

% load defaultVar.mat
% taskschedule = [0*ones(1,10) repmat([4 5],1,2*nL_T)];
% nTask = length(taskschedule);
% rotationangle = [0*ones(1,10) zeros(1,nL_T*4)];
% [nTask,iti,targetlocation,reachnoise]=genSchedule_sub...
%     (taskschedule,targetvar_theta,reachvar_thetaControl);
% save taskBase

% main session for abrupt perturbation
load defaultVar.mat
taskschedule =[zeros(1,nB_T) repmat([4 5],1,nL_T) zeros(1,nB_T) 1*ones(1,nA2_T) 6 1*ones(1,nA_T-nA2_T)...
    1*ones(1,nW_T) repmat([4 5],1,nL_T) 7 ...
    zeros(1,nW2_T)]; 
% 40B+92P+1Pause+3*(10R+5/5L)=173
rotationangle = [0*ones(1,nB_T) 0*ones(1,nL_T*2) 0*ones(1,nB_T) P*ones(1,nA2_T) 0 P*ones(1,nA_T-nA2_T)...
    P*ones(1,nW_T) 0*ones(1,nL_T*2) 0 ...
    zeros(1,nW2_T)]; 

% taskschedule =[zeros(1,nB_T) 1*ones(1,nA2_T) 6 1*ones(1,nA_T-nA2_T-2) ...
%      repmat([4 5],1,nL_T) 1*ones(1,nW_T)]; 
% % 40B+72P+1Pause+3*(5/5L+10R)=173
% rotationangle = [0*ones(1,nB_T) P*ones(1,nA2_T) 0 P*ones(1,nA_T-nA2_T-2)...
%     0*ones(1,nL_T*2) P*ones(1,nW_T)]; 


[nTask,iti,targetlocation,reachnoise]=genSchedule_sub...
    (taskschedule,targetvar_theta,reachvar_thetaControl);
save taskMainA

% main session for abrupt perturbation
load defaultVar.mat
taskschedule =[zeros(1,nB_T) repmat([4 5],1,nL_T) zeros(1,nB_T) 1*ones(1,nA2_T) 6 1*ones(1,nA_T-nA2_T)...
    1*ones(1,nW_T) repmat([4 5],1,nL_T) 7 ...
    zeros(1,nW2_T)]; 
% 40B+92P+1Pause+3*(10R+5/5L)=173
rotationangle = [0*ones(1,nB_T) 0*ones(1,nL_T*2) 0*ones(1,nB_T) 0*ones(1,nA2_T) 0 0*ones(1,nA_T-nA2_T)...
    0*ones(1,nW_T) 0*ones(1,nL_T*2) 0 ...
    zeros(1,nW2_T)]; 

% taskschedule =[zeros(1,nB_T) 1*ones(1,nA2_T) 6 1*ones(1,nA_T-nA2_T-2) ...
%      repmat([4 5],1,nL_T) 1*ones(1,nW_T)]; 
% % 40B+72P+1Pause+3*(5/5L+10R)=173
% rotationangle = [0*ones(1,nB_T) P*ones(1,nA2_T) 0 P*ones(1,nA_T-nA2_T-2)...
%     0*ones(1,nL_T*2) P*ones(1,nW_T)]; 


[nTask,iti,targetlocation,reachnoise]=genSchedule_sub...
    (taskschedule,targetvar_theta,reachvar_thetaControl);
save taskMainA_gr4


%% Temporary plot
load taskMainA
A=rotationangle; % Abrupt
Loc_x=nB_T+[1 nL_T*2]; Loc_y=[0 P];
A(nB_T+2*nL_T+nB_T+nA2_T+1)=P; % for plotting
% Plot schedule for Main experiment
figure(1) 
h1=plot(A,'b');axis([0 nTask Loc_y(1) Loc_y(2)]),set(h1,'linewidth',2.5),grid on
patch([Loc_x(1,1) Loc_x(1,2) Loc_x(1,2) Loc_x(1,1)], [Loc_y(1) Loc_y(1) Loc_y(2) Loc_y(2)],'m','FaceAlpha',0.5,'linestyle','none')
Loc_x=Loc_x+nB_T+nA_T+2*nL_T+nW_T+1;
patch([Loc_x(1,1) Loc_x(1,2) Loc_x(1,2) Loc_x(1,1)], [Loc_y(1) Loc_y(1) Loc_y(2) Loc_y(2)],'m','FaceAlpha',0.5,'linestyle','none')
% Loc_x=Loc_x+2*nL_T+nW_T;
% patch([Loc_x(1,1) Loc_x(1,2) Loc_x(1,2) Loc_x(1,1)], [Loc_y(1) Loc_y(1) Loc_y(2) Loc_y(2)],'m','FaceAlpha',0.5,'linestyle','none')
title('Perturbation schedule: Abrupt (Shade: Localization)'),xlabel('Trial'),ylabel('Angle')
hold on;
