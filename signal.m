[im_x, im_y] = size(H);
Profile = struct([]);
ProfileAv = struct([]);
data = zeros(numel(B),6);
data2 = cell(numel(B),1);

%% Number, Area, Intensity
data(:,1) = 1:numel(B);
Ddata = regionprops(comp4, D, 'Area', 'MeanIntensity');
data(:,2) = [Ddata.Area];
data(:,3) = [Ddata.MeanIntensity];

%% Gaussfilter
Hdata = regionprops(comp4,H,'MeanIntensity', 'PixelList', 'PixelValues', 'Centroid');
H2 =imgaussfilt(H,1);
data(:,4) = [Hdata.MeanIntensity];
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
        Profile{k} = improfile(H,[Hdata(i).Centroid(1) B{i}(k,2)], [Hdata(i).Centroid(2) B{i}(k,1)]);
        
        if length(Profile{k})>MaxL
            MaxL = length(Profile{k});
        end
    end
    ProfileAv{i} = zeros(MaxL,1);
    Profile2 = zeros(MaxL,length(B{i}));
    for k = 1:length(B{i})
        Profile{k} = resample(Profile{k}, MaxL, length(Profile{k}));
        Profile2(:,k) = Profile{k};
        ProfileAv{i} = ProfileAv{i} + Profile{k};
    end
    
    ProfileAv{i} = ProfileAv{i}/length(B{i});
    j = 0;
    while j == 0
        if (ProfileAv{i}(end-1) - ProfileAv{i}(end) > mean(ProfileAv{i})/20 ||...
            ProfileAv{i}(end-2) - ProfileAv{i}(end) > mean(ProfileAv{i})/20)
            ProfileAv{i}(end) = [];
        else
            j=1;
        end
    end
    data(i,5) = (-mean(ProfileAv{i}(1:(3*ceil(length(ProfileAv{i})/4)-1)))+...
        mean(ProfileAv{i}(3*ceil(length(ProfileAv{i})/4):end)))...
        /mean(ProfileAv{i});
    
    % Homogeneity
    image = H2(min(Hdata(i).PixelList(:,2)+4):max(Hdata(i).PixelList(:,2)-4),...
        min(Hdata(i).PixelList(:,1)+4):max(Hdata(i).PixelList(:,1)));
    thr = graythresh(image(image>0));
    BW = imbinarize(image,'adaptive');
    BW = imclearborder(BW);
    BW = bwareaopen(BW, 3);
    %imshow(BW);
    cc = bwconncomp(BW);
    cc2 = regionprops(cc, 'Area');
    data(i,6) = numel(cc2)/Ddata(i).Area;
    
    if data(i,6) >= 0.0035
        data2(i,1) = {'foci'};
    elseif data(i,5) >= 0.1
        data2(i,1) = {'ring'};
    else 
        data2(i,1) = {'uniform'};
    end
    
    % Plot profile and type
    image2 = figure;
    plot(1:length(ProfileAv{i}),ProfileAv{i}', 'LineWidth',2);
    text(0.05, 0.9, data2(i,1),...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized');
    image_filename = [num2str(i),'_distribution.tif'];
    print(image2, '-dtiff', '-r150', image_filename);
end
cd(filedir);
close all

