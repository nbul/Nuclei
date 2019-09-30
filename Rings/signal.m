%% Assigning memory
[im_x, im_y] = size(H);
Profile = struct([]);
ProfileAv = struct([]);
data = zeros(numel(B),6);
data2 = cell(numel(B),1);

%% Number, Area, Intensity using DAPI image
data(:,1) = 1:numel(B);
Ddata = regionprops(comp4, D, 'Area', 'MeanIntensity');
data(:,2) = [Ddata.Area];
data(:,3) = [Ddata.MeanIntensity];

%% Intensity, Pixel data and nuclei centers using gammaH2AX data
Hdata = regionprops(comp4,H,'MeanIntensity', 'PixelList', 'PixelValues', 'Centroid');
data(:,4) = [Hdata.MeanIntensity];
%% Gaussfilter to smoothen gammaH2AX signal
H2 =imgaussfilt(H,1);

%% Setting subfolder for radial distributions in this image
cd(dist_dir);
if exist([dist_dir,'/',num2str(loop)],'dir') == 0
    mkdir(dist_dir,num2str(loop));
end
graph_dir = [dist_dir,'/', num2str(loop)];
cd(graph_dir);
%% Cell-by-cell profile and class
for i = 1:numel(B)
    % profile
    MaxL = 0;
    for k = 1:length(B{i})
        %Profile from centroid to each point at the boundary
        Profile{k} = improfile(H,[Hdata(i).Centroid(1) B{i}(k,2)], [Hdata(i).Centroid(2) B{i}(k,1)]);
        
        if length(Profile{k})>MaxL
            MaxL = length(Profile{k}); % determening maximum length of the profiles
        end
    end
    % making the average profile for the nucleus
    ProfileAv{i} = zeros(MaxL,1);
    Profile2 = zeros(MaxL,length(B{i}));
    for k = 1:length(B{i})
        Profile{k} = resample(Profile{k}, MaxL, length(Profile{k}));
        Profile2(:,k) = Profile{k};
        ProfileAv{i} = ProfileAv{i} + Profile{k};
    end
    
    ProfileAv{i} = ProfileAv{i}/length(B{i});
    j = 0;
    % Removing the tail of the profile with artefacts -> the drop observed
    % due to resampling
    while j == 0
        if (ProfileAv{i}(end-1) - ProfileAv{i}(end) > mean(ProfileAv{i})/20 ||...
            ProfileAv{i}(end-2) - ProfileAv{i}(end) > mean(ProfileAv{i})/20)
            ProfileAv{i}(end) = [];
        else
            j=1;
        end
    end
    %% Perimeter intensity vs the center
    data(i,5) = (-mean(ProfileAv{i}(1:(3*ceil(length(ProfileAv{i})/4)-1)))+...
        mean(ProfileAv{i}(3*ceil(length(ProfileAv{i})/4):end)))...
        /mean(ProfileAv{i});
    
    %% Homogeneity
    image = H2(min(Hdata(i).PixelList(:,2)+4):max(Hdata(i).PixelList(:,2)-4),...
        min(Hdata(i).PixelList(:,1)+4):max(Hdata(i).PixelList(:,1))); % cropping an individual nucleus
    BW = imbinarize(image,'adaptive'); % thresholding using adaptive method to determine foci
    BW = imclearborder(BW); % removing foci at the nucleis border -> the ring
    BW = bwareaopen(BW, 3); % removing foci smaller than 3 px
    % collecting information about number and size of foci
    cc = bwconncomp(BW);
    cc2 = regionprops(cc, 'Area');
    data(i,6) = numel(cc2)/Ddata(i).Area; % number of foci divided by area
    
    %% Classifying nuclei - first foci, then profile
    if data(i,6) >= 0.0013  % Homogeneity cut-off (N objects in nucleus/area)
        data2(i,1) = {'foci'};
    elseif data(i,5) >= 0.1     % Perimeter intensity cutoff (last quadrant mean - first three quadrants mean divided by total mean)
        data2(i,1) = {'ring'};
    else 
        data2(i,1) = {'uniform'};
    end
    
    %% Plot profile and type and save the image
    image2 = figure;
    plot(1:length(ProfileAv{i}),ProfileAv{i}', 'LineWidth',2);
    text(0.05, 0.9, data2(i,1),...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized');
    image_filename = [num2str(i),'_distribution.tif'];
    print(image2, '-dtiff', '-r150', image_filename);
end
cd(filedir);
close all

