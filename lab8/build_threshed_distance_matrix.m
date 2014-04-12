function D = build_threshed_distance_matrix(M,thresh)
    frames = size(M,3);
    D = zeros(frames,frames);
    for i = 1:frames
        for j = 1:frames
            D(i,j) = sqrt(sum(sum((M(:,:,i) - M(:,:,j)).^2)));
        end
    end
    D(D>thresh) = 0;
    figure;imagesc(D),colormap(gray);
%     title('Distances');
end