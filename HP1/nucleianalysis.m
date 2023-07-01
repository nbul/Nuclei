
%% Determening paths and setting folders
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);
%Folders with images
nuclei_dir = [filedir, '/Nuclei'];
sum_dir = [filedir,'/Summary'];

cd(nuclei_dir);
files_nuclei = dir('*.tif');

Blobs = zeros(1,7);
counter = zeros(numel(files_nuclei),4);
for nucleus=1:numel(files_nuclei)
    Im = tiffreadVolume(files_nuclei(nucleus).name);
    Im2 = imadjustn(Im);
    Im3 = imgaussfilt3(Im2);
    Im_thr = imbinarize(Im3,0.7);
    Im_thr = bwareaopen(Im_thr,10);
    DD = bwconncomp(Im_thr);
    statsN = regionprops3(DD,Im,"Volume","Centroid","MeanIntensity","Solidity");
    Center = [statsN.Centroid];
    distanceblob = sqrt(Center(:,1).^2 + Center(:,2).^2 + (Center(:,3)*3.69).^2);

    index = sscanf(sprintf('%sm',files_nuclei(nucleus).name),'%d_%d_%d');
    data_blobs = [ones(numel(statsN.Volume),3).*index',[statsN.Volume],...
        [statsN.Solidity],[statsN.MeanIntensity],distanceblob];
    Blobs = [Blobs;data_blobs];
    counter(nucleus,:) = [index',numel(statsN.Volume)];
end
Blobs(1,:) = [];

cd(sum_dir);
Blobsall = rmoutliers(Blobs, 'mean');
Blobsall2 = array2table(Blobsall);
Blobsall2.Properties.VariableNames = {'image', 'nucleus', 'E-cad_signal',...
    'Volume','Solidity', 'MeanIntensity', 'Distance'};

writetable(Blobsall2,'Summary3D.xlsx','Sheet','All Blobs', 'WriteMode', 'overwritesheet');

BlobsN = array2table(counter);
BlobsN.Properties.VariableNames = {'image', 'nucleus', 'E-cad_signal',...
    'N'};

writetable(BlobsN,'Summary3D.xlsx','Sheet','Number Blobs', 'WriteMode', 'overwritesheet');