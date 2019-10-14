clc
clear variables
close all
%% Determening paths and setting folders
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);

%% Defining the channels for DAPI, gammaH2AX, and additional markers
DAPI = 1;
H2A = 2;
%% Creating folders for resutls
if exist([filedir,'/images_analysed'],'dir') == 0
    mkdir(filedir,'/images_analysed');
end
im_dir = [filedir, '/images_analysed'];

if exist([filedir,'/nuclei'],'dir') == 0
    mkdir(filedir,'/nuclei');
end
n_dir = [filedir, '/nuclei'];

Border = struct([]);
files = dir(strcat(filedir,'/*.nd2'));
counter = 0;
class = zeros(1,1);
for loop=1:numel(files)
      % reading images
    counter2 = 0;
    Number1 = [num2str(loop),'.nd2'];
    Image = bfopen(Number1);
    Image = Image{1,1};
    D = Image{DAPI,1}; % image with DAPI channel
    H = Image{H2A,1}; % Image with gammaHP2AX channel
    % identification of nuclei
    objects;
    H2 =imgaussfilt(H,1);
    Hdata = regionprops(comp4,H,'MeanIntensity', 'PixelList', 'PixelValues', 'Centroid');
    cd(n_dir);
    for i = 1:numel(B)
        image = H2(min(Hdata(i).PixelList(:,2)):max(Hdata(i).PixelList(:,2)),...
        min(Hdata(i).PixelList(:,1)):max(Hdata(i).PixelList(:,1)));
        counter = counter +1;
        counter2 = counter2 +1;
        imwrite(image, [num2str(counter),'.tif']);
        Border{counter} = B{i}-min(B{i})+1;
%         imshow(imadjust(image));
%         class(counter) = input('What is the class? 1 - uniform, 2 - foci, 3 - large foci, 4 - ring, 0 - not sure');
    end
%    csvwrite([num2str(loop),'_label.csv'], class');
    cd(filedir);
  
end
%csvwrite('label.csv', class');
cd(currdir);