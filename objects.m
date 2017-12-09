
Dsub = imgaussfilt(D,2);
Th = graythresh(imadjust(Dsub));
D2 = imbinarize(imadjust(Dsub), Th*0.7);
D2 = bwareaopen(D2, 200);
D2 = imclearborder(D2);
D2 = imdilate(D2,strel('disk',3));
D2 = imerode(D2,strel('disk',3));
D2 = imfill(D2, 'holes');
comp = bwlabel(D2);
Nuclei = regionprops(comp, D, 'Area', 'Eccentricity', 'MeanIntensity','Perimeter'); %#ok<MRPBW>
NEcc = [Nuclei.Eccentricity];
Nint = [Nuclei.MeanIntensity];
NPer = [Nuclei.Perimeter];
NArea = [Nuclei.Area];
NEccind = (NEcc < 0.8);
NEcckeep = find(NEccind);
comp2 = ismember(comp, NEcckeep);
comp2 = comp2.*comp;
NIntind = (Nint < 2*median(Nint));
NIntkeep = find(NIntind);
comp3 = ismember(comp2, NIntkeep);
comp3 = comp3.*comp2;
NPerind = (4*pi * NArea./NPer./NPer >0.85);
NPerkeep = find(NPerind);
comp4 = ismember(comp2, NPerkeep);
comp4 = comp4.*comp3;
comp4 = bwlabel(comp4);
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
