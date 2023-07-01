 int_distr = zeros(20,numel(stats.Volume));
for nuc = 1:numel(stats.Volume)
    %%convert coordiantes for relative
    all_pixels = stats.VoxelList{nuc} - stats.Centroid(nuc,:);
    distance = sqrt(all_pixels(:,1).^2 + all_pixels(:,2).^2 + (all_pixels(:,3)*3.69).^2);
    int_vs_dist = [distance, stats.VoxelValues{nuc}];
    %int_vs_dist = sortrows(int_vs_dist,1);
    int_vs_dist_norm = int_vs_dist;
    int_vs_dist_norm(:,1) = int_vs_dist_norm(:,1) / max(int_vs_dist_norm(:,1));
   
    for m = 1:20
        tempdata = int_vs_dist_norm(int_vs_dist_norm(:,1)>=(m-1)*0.05 & int_vs_dist_norm(:,1)<m*0.05,:);
        int_distr(m,nuc) = mean(tempdata(:,2));
    end

    all_pixels2 = stats.VoxelList{nuc};
    all_pixels2 = all_pixels2 - min(all_pixels2)+1;
    image = zeros(max(all_pixels2(:,1)),max(all_pixels2(:,2)),max(all_pixels2(:,3)));
    for t = 1:size(all_pixels2,1)
        image(all_pixels2(t,1),all_pixels2(t,2),all_pixels2(t,3)) = stats.VoxelValues{nuc}(t);
    end
    cd(nuclei_dir);
    image_name = [num2str(loop), '_', num2str(nuc),'_', num2str(Positive3D(nuc)), '.tif'];
    imwrite(uint16(image(:,:,1)),image_name);
    for slice = 2:max(all_pixels2(t,3))
        imwrite(uint16(image(:,:,slice)),image_name,'WriteMode','append');
    end
end
distance_all = [distance_all int_distr];

%figure
%i = 0.025:0.025:1;
%plot(i',int_distr(:,Positive'==0))
%figure
%i = 0.025:0.025:1;
%plot(i',int_distr(:,Positive'==1))
    
