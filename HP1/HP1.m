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
%Folder to save summarised information
if exist([filedir,'/Summary'],'dir') == 0
    mkdir([filedir,'/Summary']);
end
sum_dir = [filedir,'/Summary'];

if exist([filedir,'/Threshold'],'dir') == 0
    mkdir([filedir,'/Threshold']);
end
Im_dir = [filedir,'/Threshold'];

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
files_tif = dir('*.tif');

%% collecting data abount borders and corners
cd(currdir);
WithEcad = [0 0 0 0 0 0];
NoEcad = [0 0 0 0 0 0];

for loop = 1:numel(files_tif)
    cd(tif16_dir);
    HP1signal = imread([num2str(loop), '.tif']);
    %imshow(HP1signal, [min(HP1signal(:)) max(HP1signal(:))])
    HP1signal2 = imgaussfilt(HP1signal,2);
    HP1signal2 = imadjust(HP1signal2);
    level = graythresh(double(HP1signal2));
    HP1signal3 = imbinarize(HP1signal2,0.2);
    HP1signal3 = bwareaopen(HP1signal3, 500);
    HP1signal3 = imclearborder(HP1signal3);
    
    comp = bwlabel(HP1signal3);
    Nucleiall = regionprops(comp, 'Area', 'Eccentricity', 'Perimeter'); %#ok<MRPBW> % collecting properties of remaining objects/nuclei
    NEcc = [Nucleiall.Eccentricity];    
    NPer = [Nucleiall.Perimeter];
    NArea = [Nucleiall.Area];
    
    %% Eccentricity cut-off 0.8 and filtering by eccentricity (if too elongated
    NEccind = (NEcc < 0.8);
    NEcckeep = find(NEccind);
    comp2 = ismember(comp, NEcckeep);
    comp2 = comp2.*comp;
    
    %% Shape regularity cut-off 4*pi * NArea./NPer./NPer >0.85 and filtering be perimeter vs area (should be reasonable round)
    NPerind = (4*pi * NArea./NPer./NPer >0.85); % shape regularity cut-off
    NPerkeep = find(NPerind);
    comp3 = ismember(comp2, NPerkeep);
    comp3 = comp3.*comp2;
    comp3 = bwlabel(comp3);
    
    cd(tif8_dir);
    Projection = imread([num2str(loop), '.tif']);
    
    if choice == 0
        figure;
        imshow(Projection);
        [x, y] = getpts;
        close all;
        cd(label_dir);
        writetable(array2table([x, y]), [num2str(loop), '.xlsx']);
    else
        cd(label_dir);
        x = table2array(readtable([num2str(loop), '.xlsx'],'Range','A:A'));
        y = table2array(readtable([num2str(loop), '.xlsx'],'Range','B:B'));
    end
    
    
    
    CC = bwconncomp(comp3);
    Nuclei = regionprops(CC, HP1signal, 'Area', 'Eccentricity', 'Circularity', 'PixelList', 'MeanIntensity','PixelValues');
    Positive = zeros(numel(Nuclei),1);
    IntSD = zeros(numel(Nuclei),1);
    
    for n = 1:numel(Nuclei)
        IntSD(n) = std(double([Nuclei(n).PixelValues]));
        for i = 1:length(x)
            my_mat = int32([Nuclei(n).PixelList]);
            new = int32([x(i), y(i)]);
            if sum(ismember(my_mat(:,1:2), new, 'rows')) == 1
                Positive(n) = 1;
            end
        end
    end
    
    [B,L] = bwboundaries(comp3,'noholes');
    
    image1 = figure;
    imshow(HP1signal, [min(HP1signal(:)) max(HP1signal(:))]);
    hold on
    for k = 1:length(B)
        boundary = B{k};
        hold on;
        if Positive(k) == 0
            plot(boundary(:,2), boundary(:,1), 'b', 'LineWidth', 2)
        else
            plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
        end
    end
    cd(Im_dir);
    image_filename = [num2str(loop),'_segmented.tif'];
    print(image1, '-dtiff', '-r150', image_filename);
    close all;
    
    Temp = [ ones(1,numel(Nuclei))' * loop [Nuclei.Area]' [Nuclei.Eccentricity]' [Nuclei.Circularity]' [Nuclei.MeanIntensity]' IntSD];
    WithEcad = [WithEcad; Temp(Positive == 1,:)];
    NoEcad = [NoEcad; Temp(Positive == 0,:)];
end

WithEcad(1,:) = [];
WithEcad = rmoutliers(WithEcad, 'mean');
cd(sum_dir);
WithEcad2 = array2table(WithEcad);
WithEcad2.Properties.VariableNames = {'image', 'Area', 'Eccentricity', 'Circularity','MeanIntensity', 'IntensitySD'};


NoEcad(1,:) = [];
NoEcad = rmoutliers(NoEcad, 'mean');
NoEcad2 = array2table(NoEcad);
NoEcad2.Properties.VariableNames = {'image', 'Area', 'Eccentricity', 'Circularity','MeanIntensity', 'IntensitySD'};

writetable(WithEcad2,'Summary.xlsx','Sheet','With E-cad');
writetable(NoEcad2,'Summary.xlsx','Sheet','Without E-cad');
cd(currdir);
