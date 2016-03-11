%% genSchedule_sub
% Kangwoo Lee
% 9/17/2015
% This function is a subfunction of genSchedule.m.
% It is made only to reduce the lines of genSchedule code.

function [nTask,iti,targetlocation,reachnoise]=genSchedule_sub...
    (taskschedule,targetvar_theta,reachvar_thetaControl)
%% Basic variables
%rng(900); 
nTask = length(taskschedule);
I=find(taskschedule==1); n_adap=length(I); %count the number of adaptation trials
iti = 1000+500*rand(1,nTask);
%targetlocation_temp = (90-targetvar_theta)+(2*targetvar_theta)*rand(1,nTask);
targetlocation_temp = (2*targetvar_theta)*rand(1,nTask);
targetlocation=targetlocation_temp-mod(targetlocation_temp,45)+22.5; % 45= 360/8, 8 targets

%% Temporary lines
% Same number of each target setting
% tar_temp=repmat([22.5:45:337.5],1,n_adap/8); % temp!
% tar_temp = tar_temp(randperm(length(tar_temp)));

%% pseudorandom order of adaptation trials
tar_temp=[];
for a=1:(n_adap/8)
    ind= -22.5+45*randperm(8); % shuffle index for 8 targets
    tar_temp=[tar_temp ind];
end
targetlocation(I) = tar_temp; 
reachnoise = reachvar_thetaControl*randn(1,nTask); % add noise of reach angle

%% Excluding high level of noise occured by accident
% Since we add noise using gaussian distribution,
% there is a possibility that we can have high noise 
% that human would not generate in reality.
% These lines below will reject those high noise within 2*std range,
% which indicates 95% confidence level of the distribution.
temp1=find(abs(reachnoise)>reachvar_thetaControl*2); 
while(length(temp1)>0)
    reachnoise(temp1)=reachvar_thetaControl*randn(1,length(temp1));
    temp1=find(abs(reachnoise)>reachvar_thetaControl*2); 
end
end