function D = build_distance_matrix(M)
    frames = size(M,3);
    D = zeros(frames,frames);
    for i = 1:frames
        for j = 1:frames
            D(i,j) = sqrt(sum(sum((M(:,:,i) - M(:,:,j)).^2)));
        end
    end
%     figure;imagesc(D),colormap(gray);
%     title('Distances');

    % filter distance matrix with diagonal kernel
    f = [1 3 3 1];
    %Dprime = imfilter(D, diag(f));
    Dprime = D;
%     figure;imagesc(Dprime),colormap(gray);
%     title('Filtered Distances');

    % calculate anticipated future cost matrix
    alpha = 0.99;
    p = 2.5;
    Dprimeprime = Dprime.^p;

    last = Dprimeprime(:).^p;
    this = zeros(size(last));
    iterations = 0;
    while norm(last - this) > 0.1;
        for j = frames:-1:1
            m = min(Dprimeprime,[],2);
            Dprimeprime(:,j) = Dprime(:,j).^p + alpha*m(j);
        end
        last = this;
        this = Dprimeprime(:);
        iterations = iterations + 1;
    end
    disp(['converged in ' int2str(iterations) ' iterations']);

    D = Dprimeprime;
%     figure;imagesc(D),colormap(gray);
%     title('Final Distance Matrix');
end