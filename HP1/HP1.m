%% Clear all and initial parameters
clc
clear variables
close all

%% Determening paths and setting folders
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);
%Folders with images
tif16_dir = [filedir, '/HP1'];
tif8_dir =[filedir, '/projections'];
oib_dir =[filedir, '/oib'];

%Folder to save summarised information
if exist([filedir,'/Summary'],'dir') == 0
    mkdir([filedir,'/Summary']);
end
sum_dir = [filedir,'/Summary'];

if exist([filedir,'/Nuclei'],'dir') == 0
    mkdir([filedir,'/Nuclei']);
end
nuclei_dir = [filedir,'/Nuclei'];

if exist([filedir,'/Threshold'],'dir') == 0
    mkdir([filedir,'/Threshold']);
end
Im_dir = [filedir,'/Threshold'];

if exist([filedir,'/Mask'],'dir') == 0
    mkdir([filedir,'/Mask']);
end
Mask_dir = [filedir,'/Mask'];

usedefault = questdlg(strcat('Are the nuclei classified?'),'Settings','Yes','No','No');
if strcmp(usedefault, 'No')
    choice2 = 1;
else
    choice2 = 0;
end

usedefault = questdlg(strcat('Do you want to re-label the cells'),'Settings','Yes','No','No');
if strcmp(usedefault, 'No')
    choice = 1;
else
    choice = 0;
end


if exist([filedir,'/Labels'],'dir') == 0
    mkdir([filedir,'/Labels']);
end
label_dir = [filedir,'/Labels'];

cd(tif8_dir);
files = dir('*.tif');

HP1_2D;

HP1_3D;

%% saving aggregated data
cd(sum_dir);

if choice2 == 0
    WithEcadall = [WithEcad, WithEcad3D];
    WithEcadall(1,:) = [];
    WithEcadall = rmoutliers(WithEcadall, 'mean');
    WithEcadall2 = array2table(WithEcadall);
    WithEcadall2.Properties.VariableNames = {'image', 'Area', 'Eccentricity',...
        'Circularity','MeanIntensity', 'IntensitySD', 'X', 'Y',...
        'Volume', 'SurfaceArea','Solidity','MeanIntensity3D','Zposition','Height'};
   
    NoEcadall = [NoEcad, NoEcad3D];
    NoEcadall(1,:) = [];
    NoEcadall = rmoutliers(NoEcadall, 'mean');
    NoEcadall2 = array2table(NoEcadall);
    NoEcadall2.Properties.VariableNames ={'image', 'Area', 'Eccentricity',...
        'Circularity','MeanIntensity', 'IntensitySD', 'X', 'Y',...
        'Volume', 'SurfaceArea','Solidity','MeanIntensity3D','Zposition', 'Height'};

    writetable(WithEcadall2,'Summary3D.xlsx','Sheet','With E-cad','WriteMode','overwritesheet');
    writetable(NoEcadall2,'Summary3D.xlsx','Sheet','Without E-cad','WriteMode', 'overwritesheet');
else
    AllNucleiall = [AllNuclei, AllNuclei3D];
    AllNucleiall(1,:) = [];
    AllNucleiall = rmoutliers(AllNucleiall, 'mean');
    AllNucleiall2 = array2table(AllNucleiall);
    AllNucleiall2.Properties.VariableNames = {'image', 'Area', 'Eccentricity',...
        'Circularity','MeanIntensity', 'IntensitySD', 'X', 'Y',...
        'Volume', 'SurfaceArea','Solidity','MeanIntensity3D','Zposition', 'Height'};

    writetable(AllNucleiall2,'Summary3D.xlsx','Sheet','All Nuclei', 'WriteMode', 'overwritesheet');
end
cd(currdir);

nucleisignal;

nucleianalysis;