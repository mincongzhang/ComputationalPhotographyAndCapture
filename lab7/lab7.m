function output = labs6(path, prefix, first, last, digits, suffix)
    close all;

    % set the random seed to get comparable results between runs
    s = RandStream('mt19937ar','Seed',0);
    RandStream.setGlobalStream(s);

    M = load_sequence(path, prefix, first, last, digits, suffix);

    D = build_distance_matrix(M);

    P = build_probability_matrix(D);
    % figure;imagesc(P),colormap(gray);
    % title('Transition Matrix P');

    nframes = 300;
    sequence = generate_sequence(M,P,nframes);

    output(nframes) = struct('cdata',[],'colormap',[]);
    for f = 1:nframes
        imshow(sequence(:,:,f));
        output(f) = getframe;
    end
end

function D = build_distance_matrix(M)
    frames = size(M,3);
    D = zeros(frames,frames);
    for i = 1:frames
        for j = 1:frames
            D(i,j) = sqrt(sum(sum((M(:,:,i) - M(:,:,j)).^2)));
        end
    end
    % figure;imagesc(D),colormap(gray);
    % title('Distances');

    % filter distance matrix with diagonal kernel
    f = [1 3 3 1];
    Dprime = imfilter(D, diag(f));
    % figure;imagesc(Dprime),colormap(gray);
    % title('Filtered Distances');

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
    % figure;imagesc(D),colormap(gray);
    % title('Final Distance Matrix');

    D = Dprimeprime;
end


function output = build_probability_matrix(D)
    % set to average of nonzero D values
    sigma = 0.2*mean(nonzeros(D));

    output = exp(-D/sigma);

    output = [output(2:end,:); zeros(1,size(output,2))];

    % normalise each row
    for i = 1:size(output,1)
        output(i,:) = output(i,:)/sum(output(i,:));
    end
end

function output = generate_sequence(M,P,nframes)
    % pre-allocate output sequence
    output = zeros(size(M,1),size(M,2),nframes);

    random_start_frame = ceil(size(M,3)*rand);
    output(:,:,1) = M(:,:,random_start_frame);

    i = random_start_frame;
    for frame = 2:nframes
        % Find frame j similar to frame i+1 (i -> i+1 in P)
        j = importance_sample(P(i,:));
        output(:,:,frame) = M(:,:,j);
        i = j;
    end
end

function j = importance_sample(row)
% takes a row of probabilities and returns a (biased) random sample
    [sorted, indices] = sort(row,2,'descend');
    sorted = sorted(1:5); % hack: make sure only the top few have a chance
    sorted = sorted / sum(sorted); % normalize after hack
    prob = rand(1);
    csum = cumsum(sorted);
    j = 1;
    while csum(j) < prob
        j = j + 1;
    end
    j = indices(j);
end