%% saving stats for each image and calculating averaged values
cd(stat_dir);
if BP1 > 0
    dataAll = [num2cell(data), data2, num2cell(dataB)]; % all data combined together
    dataTitle = {'Nucleus', 'Area', 'DAPI intensity', 'gH2AX intensity', 'gH2AX periphery/center',...
        'gH2AX homogeneity', 'Signal class', '53BP1 intensity', 'gH2AX/53BP1 correlation', 'p-value'};
    dataAll = [dataTitle; dataAll]; % all data with a header
    cell2csv([num2str(loop),'.csv'], dataAll); % saving file with data for each image
    imnumber = ones(size(dataAll,1)-1,1)*loop; % creating first column with image number
    imnumber = [num2cell(imnumber), dataAll(2:end,:)]; % adding first column to the rest of the data
    datapulled = [datapulled; imnumber]; % pulling the data
    avdata(loop, 1) = loop;     %number of image
    avdata(loop, 2) = numel(B); %number of nuclei in image
    avdata(loop, 3) = mean(data(:,2)); % average area
    avdata(loop, 4) = std(data(:,2)); % SD area
    avdata(loop, 5) = mean(data(:,3)); % average DAPI intensity
    avdata(loop, 6) = std(data(:,3)); % SD DAPI intensity
    avdata(loop, 7) = mean(data(:,4)); % average gH2AX intensity
    avdata(loop, 8) = std(data(:,4)); % SD gH2AX intensity
    avdata(loop, 9) = mean(dataB(:,1)); % average 53BP1 intensity
    avdata(loop, 10) = std(dataB(:,1)); % SD 53BP1 intensity
    avdata(loop, 11) = mean(dataB(:,2)); % average correlation
    avdata(loop, 12) = std(dataB(:,2)); % SD correlation
    avdata(loop, 13) = 100*sum(contains(data2, 'foci'))/numel(B); % cells with foci
    avdata(loop, 14) = 100*sum(contains(data2, 'uniform'))/numel(B); % cells with uniform
    avdata(loop, 15) = 100*sum(contains(data2, 'ring'))/numel(B); % cells with rings
else
    dataAll = [num2cell(data), data2]; % all data combined together
    dataTitle = {'Nucleus', 'Area', 'DAPI intensity', 'gH2AX intensity', 'gH2AX periphery/center',...
        'gH2AX homogeneity', 'Signal class'};
    dataAll = [dataTitle; dataAll]; % all data with a header
    cell2csv([num2str(loop),'.csv'], dataAll);  % saving file with data for each image
    imnumber = ones(size(dataAll,1)-1,1)*loop; % creating first column with image number
    imnumber = [num2cell(imnumber), dataAll(2:end,:)];  % adding first column to the rest of the data
    datapulled = [datapulled; imnumber];  % pulling the data
        avdata(loop, 1) = loop;     %number of image
    avdata(loop, 2) = numel(B); %number of nuclei in image
    avdata(loop, 3) = mean(data(:,2)); % average area
    avdata(loop, 4) = std(data(:,2)); % SD area
    avdata(loop, 5) = mean(data(:,3)); % average DAPI intensity
    avdata(loop, 6) = std(data(:,3)); % SD DAPI intensity
    avdata(loop, 7) = mean(data(:,4)); % average gH2AX intensity
    avdata(loop, 8) = std(data(:,4)); % SD gH2AX intensity
    avdata(loop, 9) = 100*sum(contains(data2, 'foci'))/numel(B); % cells with foci
    avdata(loop, 10) = 100*sum(contains(data2, 'uniform'))/numel(B); % cells with uniform
    avdata(loop, 11) = 100*sum(contains(data2, 'ring'))/numel(B); % cells with rings
end
cd(filedir);