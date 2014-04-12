function DG = buildDGmatrix(M)

    D = build_distance_matrix(M);
    %D = build_threshed_distance_matrix(M,19);
    
    %normalize D and get sparse
    D(:,end) = D(:,end).*inf;
    D(end,:) = D(end,:).*inf;

    DG = sparse(D);
    save('buildDGmatrix.mat','DG','M');
end