dataB = zeros(numel(B),3);


cd(corr_dir);
%% Making directory for each image
if exist([corr_dir,'/',num2str(loop)],'dir') == 0
    mkdir(corr_dir,num2str(loop));
end
graph2_dir = [corr_dir,'/', num2str(loop)];
cd(graph2_dir);

%% Collecting 53BP1 signal intensity
Bdata = regionprops(comp4,BP,'MeanIntensity', 'PixelValues');
dataB(:,1) = [Bdata.MeanIntensity];
%% Correlation H2A with BP1
for i = 1:numel(B)
    [dataB(i,2),dataB(i,3)] = corr(double([Hdata(i).PixelValues]), double([Bdata(i).PixelValues])); % Correlation coeffitient
    image3 = figure;
    scatter(double([Hdata(i).PixelValues]), double([Bdata(i).PixelValues]),8,'r', 'o', 'filled'); % scatter plot with gammaH2AX vs 53BP1 intensities
    text(0.05, 0.9, ['P = ', num2str(dataB(i,2)), ';  p = ', num2str(dataB(i,3))],...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized'); % Add correlation coefficient on the plot
    xlabel('gH2AX', 'FontSize', 18, 'FontWeight', 'bold') % x-axis label
    ylabel('53BP1', 'FontSize', 18, 'FontWeight', 'bold') % y-axis label
    % save image
    image_filename = [num2str(i),'correlation.tif'];
    print(image3, '-dtiff', '-r150', image_filename);
end
close all;
cd(filedir);
