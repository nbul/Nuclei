%% Identification of nuclei using the DAPI channel
Dsub = imgaussfilt(D,2); % smoothen signal to get complete objects
Th = graythresh(imadjust(Dsub)); % determine threshold
D2 = imbinarize(imadjust(Dsub), Th*0.7); % binarize image using a 0.7 threshold to exclude holes
D2 = bwareaopen(D2, 400); % Removing noise/dirt -> objects that are smaller than 400 px
D2 = imclearborder(D2); % Removing objects which directly tooch borders -> incomplete nuclei
D2 = imdilate(D2,strel('disk',3)); % series of dilation, erosion and hole-filling to get complete nuclei, parameters are set bit trial approach
D2 = imerode(D2,strel('disk',3));
D2 = imfill(D2, 'holes');
comp = bwlabel(D2);

Nuclei = regionprops(comp, D, 'Area', 'Eccentricity', 'MeanIntensity','Perimeter'); %#ok<MRPBW> % collecting properties of remaining objects/nuclei
NEcc = [Nuclei.Eccentricity];
Nint = [Nuclei.MeanIntensity];
NPer = [Nuclei.Perimeter];
NArea = [Nuclei.Area];

%% Eccentricity cut-off 0.8 and filtering by eccentricity (if too elongated
NEccind = (NEcc < 0.8); 
NEcckeep = find(NEccind);
comp2 = ismember(comp, NEcckeep);
comp2 = comp2.*comp;

%% Intendity cut-off 2*median DAPI signal and filtering by intensity (if too bright - artefacts and dying)
NIntind = (Nint < 2*median(Nint)); % Dapi cut-off
NIntkeep = find(NIntind);
comp3 = ismember(comp2, NIntkeep);
comp3 = comp3.*comp2;

%% Shape regularity cut-off 4*pi * NArea./NPer./NPer >0.85 and filtering be perimeter vs area (should be reasonable round)
NPerind = (4*pi * NArea./NPer./NPer >0.85); % shape regularity cut-off
NPerkeep = find(NPerind);
comp4 = ismember(comp2, NPerkeep);
comp4 = comp4.*comp3;
comp4 = bwlabel(comp4);

%% Determening boundaries and centers of remaining objects, 
%% and protting/saving image where borders and nuclei numbers are overlaid on DAPI signal image
[B,L] = bwboundaries(comp4);
Nuclei2 = regionprops(comp4, 'Centroid'); %#ok<MRPBW>

image1=figure;
imshow(imadjust(H));
hold on;
for k = 1:length(B)
    clear boundary_valid
    boundary = B{k};
    c = Nuclei2(k).Centroid;
    c_labels = text(c(1), c(2), sprintf('%d', k),'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle', 'Fontsize', 10);
    set(c_labels,'Color',[1 1 0])
    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
end

%% Saving the image
cd(im_dir);
image_filename = [num2str(loop),'_analysed_image.tif'];
print(image1, '-dtiff', '-r150', image_filename);
cd(filedir);
close all
