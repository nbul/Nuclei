dataB = zeros(numel(B),3);

%% Correlation H2A with BP1
cd(corr_dir);
if exist([corr_dir,'/',num2str(loop)],'dir') == 0
    mkdir(corr_dir,num2str(loop));
end
graph2_dir = [corr_dir,'/', num2str(loop)];
cd(graph2_dir);
Bdata = regionprops(comp4,BP,'MeanIntensity', 'PixelValues');
dataB(:,1) = [Bdata.MeanIntensity];
for i = 1:numel(B)
    [dataB(i,2),dataB(i,3)] = corr(double([Hdata(i).PixelValues]), double([Bdata(i).PixelValues])); 
    image3 = figure;
    scatter(double([Hdata(i).PixelValues]), double([Bdata(i).PixelValues]),8,'r', 'o', 'filled');
    text(0.05, 0.9, ['P = ', num2str(dataB(i,2)), ';  p = ', num2str(dataB(i,3))],...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized');
    image_filename = [num2str(i),'correlation.tif'];
    print(image3, '-dtiff', '-r150', image_filename);
end
close all;
cd(filedir);
