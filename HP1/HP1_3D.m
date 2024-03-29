
WithEcad3D = [0 0 0 0 0 0];
NoEcad3D = [0 0 0 0 0 0];
AllNuclei3D = [0 0 0 0 0 0];
count3D = zeros(numel(files),1);
distance_all = zeros(20,1);
positive_all = 0;
for loop = 1:numel(files)
    cd(Mask_dir);
    Mask = imread([num2str(loop), '_mask.tif']);
    Mask = imbinarize(Mask,0.1);
    

    cd(oib_dir);
    filename = [num2str(loop), '.oib'];
    original = bfopen(filename);
    
    Series = original{1,1};
    seriesCount = size(Series, 1); %display size to check type of file
    HP1 = struct([]);
   
    FinalImage = zeros(size(HP1signal3,1), size(HP1signal3,2),seriesCount/3*4);
    FinalImage2 = zeros(size(HP1signal3,1), size(HP1signal3,2),seriesCount/3);
    Mask3D = zeros(size(HP1signal3,1), size(HP1signal3,2),seriesCount/3*4);
    Mask3D_2 = zeros(size(HP1signal3,1), size(HP1signal3,2),seriesCount/3);
    for plane = 1:(seriesCount/3)
        HP1{plane} = Series{plane*3,1};
        FinalImage(:,:, plane*4-3) = HP1{plane};
        FinalImage(:,:, plane*4-2) = HP1{plane};
        FinalImage(:,:, plane*4-1) = HP1{plane};
        FinalImage(:,:, plane*4) = HP1{plane};
        FinalImage2(:,:, plane) = HP1{plane};
        Mask3D(:,:, plane*4-3) = Mask;
        Mask3D(:,:, plane*4-2) = Mask;
        Mask3D(:,:, plane*4-1) = Mask;
        Mask3D(:,:, plane*4) = Mask;
        Mask3D_2(:,:,plane) = Mask;
    end  
    
    %Segmented = activecontour(FinalImage,Mask3D,50);
    Segmented2 = activecontour(FinalImage2,Mask3D_2,50);
    %volshow(FinalImage)
    Segmented3 = bwareaopen(Segmented2,1000);
    stats = regionprops3(Segmented3,FinalImage2,"Volume","VoxelList","SurfaceArea",...
        "Solidity","MeanIntensity","VoxelValues", "Centroid");
    
    %% classifying nuclei
    Positive3D = zeros(numel(stats.Volume),1);
    Height = zeros(numel(stats.Volume),1);
    if choice2 == 0
        cd(label_dir);
        Coordinates = int32(table2array(readtable([num2str(loop), '.xlsx'])));
        for n = 1:numel(stats.Volume)
            for i = 1:size(Coordinates,1)
                my_mat3D = int32([stats.VoxelList{n,1}]);               
                Height(n) = 0.38*double(max(my_mat3D(:,3)) - min(my_mat3D(:,3))+1); 
                if sum(ismember(my_mat3D(:,1:2), Coordinates(i,:), 'rows')) >= 1
                    Positive3D(n) = 1;
                end
            end
        end
    end
    positive_all = [positive_all; Positive3D];
    
    %% Collecting nuclei shape and mean intensity
      %% collecting the data
    Temp3D = [[stats.Volume] [stats.SurfaceArea] [stats.Solidity] [stats.MeanIntensity]...
        [stats.Centroid(:,3)] Height];
    if choice2 == 0
        WithEcad3D = [WithEcad3D; Temp3D(Positive3D == 1,:)];
        NoEcad3D = [NoEcad3D; Temp3D(Positive3D == 0,:)];
    else
        AllNuclei3D = [AllNuclei3D; Temp3D];
    end
    count3D(loop) = numel(stats.Volume);
    nucleisignal;
end


figure
i = 0.05:0.05:1;
Minus = mean(distance_all(:,positive_all'==0),2)-33;
MinusSD = std(distance_all(:,positive_all'==0),0, 2)/sqrt(length(positive_all)-sum(positive_all));
Plus = mean(distance_all(:,positive_all'==1),2)-33;
PlusSD = std(distance_all(:,positive_all'==1),0,2)/sqrt(sum(positive_all));
errorbar(i',Minus,MinusSD,"-b");
hold on;
errorbar(i',Plus,PlusSD,"-r");

