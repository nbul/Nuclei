clc
clear variables
close all
%% Determening paths and setting folders
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);
image = struct([]);
Profile = struct([]);
files = dir('*.tif');
for i=1:numel(files)
    image{i} = imread([num2str(i), '.tif']);
end
ProfileAv = struct([]);
data = zeros(numel(files),13);
for i=1:numel(files)
   
    temp = image{i}(:);
    data(i,1) = i;
    data(i,2) = mean(temp(temp>0));
    data(i,3) = std(double(temp(temp>0)));
    H = imhist(image{i});
    data(i,4) = skewness(H);
    data(i,5) = kurtosis(H);
%     thresh = multithresh(image{i},8);
%     temp2 = imquantize(image{i}, thresh);
%     RGB = label2rgb(temp2); 
%     imshow(RGB)
    GLCM = graycomatrix(image{i},'NumLevels',8,'GrayLimits',[]);
    STATs = graycoprops(GLCM,'all');
    data(i,6) = STATs.Contrast;
    data(i,7) = STATs.Correlation;
    data(i,8) = STATs.Energy;
    data(i,9) = STATs.Homogeneity;
    
    GLCM2 = graycomatrix(image{i},'Offset',[5 0], 'NumLevels',8,'GrayLimits',[]);
    STATs2 = graycoprops(GLCM,'all');
    data(i,10) = STATs2.Contrast;
    data(i,11) = STATs2.Correlation;
    data(i,12) = STATs2.Energy;
    data(i,13) = STATs2.Homogeneity;
    
    BW = imbinarize(image{i},'adaptive'); % thresholding using adaptive method to determine foci
    BW = imclearborder(BW); % removing foci at the nucleis border -> the ring
    BW = bwareaopen(BW, 3);
    
    cc = bwconncomp(BW);
    cc2 = regionprops(cc, 'Area');
    data(i,14) = numel(cc2)/length(temp);
    
    radius_range = 0:22;
    intensity_area = zeros(size(radius_range));
    for counter = radius_range
        remain = imopen(image{i}, strel('disk', counter));
        intensity_area(counter + 1) = sum(remain(:));
    end
    
    [N, I] = min(diff(intensity_area));
    data(i,15) = I;
    
       MaxL = 0;
    [im_y, im_x] = size(image{i});
    for k = 1:length(Border{i})
        %Profile from centroid to each point at the boundary
        Profile{k} = improfile(image{i},[ceil(im_x/2) Border{i}(k,2)],...
            [ceil(im_y/2) Border{i}(k,1)]);
        
        if length(Profile{k})>MaxL
            MaxL = length(Profile{k}); % determening maximum length of the profiles
        end
    end
    % making the average profile for the nucleus
    ProfileAv{i} = zeros(MaxL,1);
    Profile2 = zeros(MaxL,length(Border{i}));
    for k = 1:length(Border{i})
        Profile{k} = resample(Profile{k}, MaxL, length(Profile{k}));
        Profile2(:,k) = Profile{k};
        ProfileAv{i} = ProfileAv{i} + Profile{k};
    end
    
    ProfileAv{i} = ProfileAv{i}/length(Border{i});
    j = 0;
    % Removing the tail of the profile with artefacts -> the drop observed
    % due to resampling
    while j == 0
        if (ProfileAv{i}(end-1) - ProfileAv{i}(end) > mean(ProfileAv{i})/10 ||...
            ProfileAv{i}(end-2) - ProfileAv{i}(end) > mean(ProfileAv{i})/10)
            ProfileAv{i}(end) = [];
        else
            j=1;
        end
    end

    %% Perimeter intensity vs the center
    data(i,16) = (-mean(ProfileAv{i}(1:(3*ceil(length(ProfileAv{i})/4)-1)))+...
        mean(ProfileAv{i}(3*ceil(length(ProfileAv{i})/4):end)))...
        /mean(ProfileAv{i});
end

% Z = linkage(data(:,2:end));
% dendrogram(Z)
T2 = clusterdata(data(:,2:end),'Linkage','ward','Maxclust',5); 
scatter3(data(:,5),data(:,11),data(:,13),100,T2,'filled');

for i=1:numel(files)
    cd([filedir,'/',num2str(T2(i))]);
    imwrite(image{i}, [num2str(i),'.tif']);
    cd(filedir);
end

D = array2table(data);
D.Properties.VariableNames = {'Nucleus', 'Mean', 'Std','Skewness',...
    'Kurtosis', 'Contrast', 'Correlation','Energy','Homogeneity',...
    'ContrastOff5', 'CorrelationOff5','EnergyOff5','HomogeneityOff5',...
    'SignalArea','BlobsArea', 'Profile'};
