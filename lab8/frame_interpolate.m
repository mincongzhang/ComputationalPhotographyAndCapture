function interpolate_frames = frame_interpolate(im1,im2)
%output frames include start frame, exclude end frame

im1 = im2double(im1);
im2 = im2double(im2);

    %%
    %Get optical flow
    addpath('mex');
    % set optical flow parameters (see Coarse2FineTwoFrames.m for the definition of the parameters)
    alpha = 0.012;
    ratio = 0.75;
    minWidth = 20;
    nOuterFPIterations = 7;
    nInnerFPIterations = 1;
    nSORIterations = 30;

    para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

    tic;
    [VX,VY,~] = Coarse2FineTwoFrames(im1,im2,para);
    toc;

    %%
    %Interpolate according to optical flow
    [row col dim] = size(im1);
     startFrame  = im1;
     endFrame    = im2;

    %get interpolate frame number
    interpolate_num = round(max(max(VX(:)),max(VY(:))));
    
    interpolate_frames = zeros(row,col,dim,interpolate_num+1);
    intermediate1 = startFrame;
    intermediate2 = endFrame;

    %initial with start frame to reduce artifact
    for n = 1:interpolate_num+1
        interpolate_frames(:,:,:,n) = startFrame;
    end
    
    % mix interpolating between start frame and end frame
    for n = 2:interpolate_num+1
        for i = 1:row
            for j = 1:col
                for d = 1:dim
                        % 1. from start frame
                        %backward mapping to prevent holes in result image
                        x = j-VX(i,j)/interpolate_num*(n-1); % col 
                        y = i-VY(i,j)/interpolate_num*(n-1); % row
                        x = round(x);
                        y = round(y);
                        if(x<=col && x>0 && y<=row && y>0)
                            intermediate1(i,j,d) = startFrame(y,x,d);
                        end

                        % 2. from end frame
                        %backward mapping to prevent holes in result image
                        x = j+VX(i,j)/interpolate_num*(interpolate_num-(n-1)); % col 
                        y = i+VY(i,j)/interpolate_num*(interpolate_num-(n-1)); % row
                        x = round(x);
                        y = round(y);
                        if(x<=col && x>0 && y<=row && y>0)
                            intermediate2(i,j,d) = endFrame(y,x,d);
                        end

                        %mix with weight
                        interpolate_frames(i,j,d,n) = (1-(n-1)/interpolate_num)*intermediate1(i,j,d) + (n-1)/interpolate_num*intermediate2(i,j,d);
                end
            end
        end
    end
    
end

