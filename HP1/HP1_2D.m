%% collecting data abount borders and corners
WithEcad = [0 0 0 0 0 0 0 0];
NoEcad = [0 0 0 0 0 0 0 0];
AllNuclei = [0 0 0 0 0 0 0 0];

count = zeros(numel(files),1);

for loop = 1:numel(files)
    %% open and threshold HP1 signal from projections
    cd(tif16_dir);
    HP1signal = imread([num2str(loop), '.tif']);
    %imshow(HP1signal, [min(HP1signal(:)) max(HP1signal(:))])
    HP1signal2 = imgaussfilt(HP1signal,2);
    HP1signal2 = imadjust(HP1signal2);
    HP1signal3 = imbinarize(HP1signal2,0.2);
    HP1signal3 = bwareaopen(HP1signal3, 500);
    HP1signal3 = imclearborder(HP1signal3);

    %% collect object properties
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

    %% Properties of nuclei that pass the selection
    CC = bwconncomp(comp3);
    Nuclei = regionprops(CC, HP1signal, 'Area', 'Eccentricity', 'Circularity',...
        'PixelList', 'MeanIntensity','PixelValues','Centroid');
    Positive = zeros(numel(Nuclei),1);
    IntSD = zeros(numel(Nuclei),1);

    %% either labelling nuclei for classification or loading the labels
    if choice == 0
        cd(tif8_dir);
        Projection = imread([num2str(loop), '.tif']);
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

    %% classifying objects
    for n = 1:numel(Nuclei)
        IntSD(n) = std(double([Nuclei(n).PixelValues]));
        if choice2 == 0
            for i = 1:length(x)
                my_mat = int32([Nuclei(n).PixelList]);
                new = int32([x(i), y(i)]);
                if sum(ismember(my_mat(:,1:2), new, 'rows')) == 1
                    Positive(n) = 1;
                end
            end
        end
    end

    %% saving classified and threshold images
    [B,L] = bwboundaries(comp3,'noholes');
    image1 = figure;
    imshow(HP1signal, [min(HP1signal(:)) max(HP1signal(:))]);
    hold on
    Centr = zeros(numel(Nuclei),2);
    for k = 1:length(B)
        boundary = B{k};
        hold on;
        c = Nuclei(k).Centroid;
        Centr(k,:) = [c(1) c(2)];
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

    cd(Mask_dir);
    image_filename = [num2str(loop),'_mask.tif'];
    imwrite(comp3, image_filename);

    %% collecting the data
    Temp = [ ones(1,numel(Nuclei))' * loop [Nuclei.Area]' [Nuclei.Eccentricity]'...
        [Nuclei.Circularity]' [Nuclei.MeanIntensity]' IntSD Centr];
    if choice2 == 0
        WithEcad = [WithEcad; Temp(Positive == 1,:)];
        NoEcad = [NoEcad; Temp(Positive == 0,:)];
    else
        AllNuclei = [AllNuclei; Temp];
    end
    count(loop) = numel(Nuclei);
end

%% saving aggregated data
