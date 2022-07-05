clear all;clc;
close all 
tic
global Npv Nwt Hr_D % identfiy your variables as global    
nvar = 2; % no. of variables

% initialization.
pop_size = 100;
G_size =100; % no. of iterations
 lb=[1000  0];            % lower limits of variables
 ub=[300000  200000]; % upper limits of variables

% Optimization
opts = psoptimset;               
[var,opt_value,REASON,OUTPUt,POPULATION,SCORES] = ga(@obj_ga_project,nvar,...
    [],[],[],[],lb,ub,[],opts);
toc
var;
var(1) = ceil (var(1));                     %round to nearest greater integer
var(2) = floor (var(2));
fprintf('No. of PV = %4.2f \n', var(1));
fprintf('No. of WT= %4.2f \n', var(2));

 
[TNPC,COE,LPSP,p,b,Nb,Nd]=MainProgramm(var(1), var(2));
fprintf('No. of diesel units = %10.3f \n', Nd);
fprintf('No. of Batteries = %10.3f \n', Nb);

fprintf('Total net present cost=%10.3f \n', TNPC);
fprintf('COE=%10.3f \n', COE);
fprintf('loss_of_P_S_probability=%10.3f \n', LPSP);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Piechart plot
explode=[1,1,1,1];
h = pie(p,explode);
if p(1)==0;
    hText = findobj(h,'Type','text'); % text handles
percentValues = get(hText,'String'); % percent values
str = {'PV: ';'Diesel: ';'Battery: '}; % text
combinedstrings = strcat(str,percentValues); % text and percent values
oldExtents_cell = get(hText,'Extent'); % cell array
oldExtents = cell2mat(oldExtents_cell); % numeric array
set(hText,{'String'},combinedstrings);
else
    hText = findobj(h,'Type','text'); % text handles
percentValues = get(hText,'String'); % percent values
str = {'Wind: ';'PV: ';'Diesel: ';'Battery: '}; % text
combinedstrings = strcat(str,percentValues); % text and percent values
oldExtents_cell = get(hText,'Extent'); % cell array
oldExtents = cell2mat(oldExtents_cell); % numeric array
set(hText,{'String'},combinedstrings);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Bars plot
Y = b(1:24,:);
figure;
bar(Y);
set(gca,'Xtick',[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24]);
xlabel ('Time (hours)')
ylabel ('Power (Kw)')
grid
legend('Load demand','Wind','PV','Batteries','Diesel','Dump')