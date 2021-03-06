clc
clear variables
close all
%% Determening paths and setting folders
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);

DAPI = 1;
H2A = 2;
BP1 = 3;
parameters = inputdlg({'DAPI channel:','yH2AX channel', '53BP1 channel:'},...
    'Parameters',1,{num2str(DAPI), num2str(H2A), num2str(BP1)});
% Redefine extension
DAPI = str2double(parameters{1});
H2A = str2double(parameters{2});
BP1 = str2double(parameters{3});

if exist([filedir,'/images_analysed'],'dir') == 0
    mkdir(filedir,'/images_analysed');
end
im_dir = [filedir, '/images_analysed'];

if exist([filedir,'/distributions'],'dir') == 0
    mkdir(filedir,'/distributions');
end
dist_dir = [filedir, '/distributions'];

if exist([filedir,'/correlarions'],'dir') == 0
    mkdir(filedir,'/correlarions');
end
corr_dir = [filedir, '/correlarions'];

if exist([filedir,'/cellbycelldata'],'dir') == 0
    mkdir([filedir,'/cellbycelldata']);
end
stat_dir = [filedir,'/cellbycelldata'];

files = dir(strcat(filedir,'/*', '_w1.TIF'));
if BP1 > 0
    datapulled = {'Image', 'Nucleus', 'Area', 'DAPI intensity', 'gH2AX intensity', 'gH2AX periphery/center',...
        'gH2AX homogeneity', 'Signal class', '53BP1 intensity', 'gH2AX/53BP1 correlation', 'p-value'};
    avdata = zeros(numel(files),15);
else
    datapulled = {'Image','Nucleus', 'Area', 'DAPI intensity', 'gH2AX intensity', 'gH2AX periphery/center',...
        'gH2AX homogeneity', 'Signal class'};
    avdata = zeros(numel(files),11);
end

for loop=1:numel(files)
    DName = [num2str(loop),'_w',num2str(DAPI),'.TIF'];    
    D = imread(DName);
    HName = [num2str(loop),'_w',num2str(H2A),'.TIF'];    
    H = imread(HName);
    % identification of nuclei
    objects;
    % gH2AX signal
    signal;
    % 53BP1 signal 
    if BP1 > 0
         BName = [num2str(loop),'_w',num2str(BP1),'.TIF'];    
         BP = imread(BName);
         BPcorr;
    end
    % summary for individual images
    summary;
end
%% writing pulled and average data
cd(stat_dir);
if BP1 > 0
    Header = {'Image', 'N', 'Area', 'SD', 'DAPI', 'SD', 'gH2AX', 'SD',...
        '53BP1', 'SD', 'Correlation', 'SD', '% foci', '% uniform', '% rings'};
    avdata = [Header; num2cell(avdata)];
else
    Header = {'Image', 'N', 'Area', 'SD', 'DAPI', 'SD', 'gH2AX', 'SD',...
         '% foci', '% uniform', '% rings'};
    avdata = [Header; num2cell(avdata)];
end
cell2csv('stats_averaged.csv', avdata);
cell2csv('stats_all.csv', datapulled);

cd(currdir);
clc
clear variables
close all