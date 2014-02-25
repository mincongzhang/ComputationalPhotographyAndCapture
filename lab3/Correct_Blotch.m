function mov = Correct_Blotch(mov,d) 
%This function firstly enhances pixels that differ from previous and next
%frames, and takes the results as protential blotches. Then it detects the
%pixels that is caused by the motion, by finding if this pixel is
%similar to its right or left side from previous and next frames.
%After deducting motion pixels, the pixels that are not detected as blotches 
%from previous and next two frames are taken to fix the blotch pixels.


%define threshold
laplacian_thresh = 10;
motion_thresh = 20;

mov1 = mov;
mov2 = mov;
mov3 = mov;

%stagger for efficient calculate
%e.g. frame [1 2 3 4 5] after staggering
%we have frame[1 2 3],frame[2 3 4] and frame[3 4 5]
mov1(:,:,end-1:end) = [];
mov2(:,:,1) = [];
mov2(:,:,end) = [];
mov3(:,:,1:2) = [];

disp('constructing raw blotch matrix ...')
%find laplacian feature between frames (enhance pixels that differ from previous and next frame) 
%[0.5 -1 0.5] is proportion to the result of lablacian filter [1 -2 1], no need to convert frame to double
laplacian = imabsdiff(0.5*mov1+0.5*mov3,mov2); 

blotch_flag = zeros(size(laplacian));
blotch_flag(laplacian>laplacian_thresh) = 1;

%ignore the boundary pixels
blotch_flag(1,:,:)=0;
blotch_flag(end,:,:)=0;
blotch_flag(:,1,:)=0;
blotch_flag(:,end,:)=0;

% get row,col,frame index in multiple dimensions
[row,col,fr] = ind2sub(size(blotch_flag), find(blotch_flag==1)); 

disp('deducting motion pixels...')
%get index length
index_length = length(row);

for i = 1:index_length
    currentframe = fr(i)+1;
    I = mov(row(i),col(i),currentframe);
    %detect motion from previous and next frames
    left_motion =  [ mov(row(i),col(i)+1,currentframe-1)-I<motion_thresh,mov(row(i),col(i)-1,currentframe-1)-I<motion_thresh];
    right_motion = [ mov(row(i),col(i)+1,currentframe+1)-I<motion_thresh,mov(row(i),col(i)-1,currentframe+1)-I<motion_thresh];
    % if the pixel only appears in one direction, delete it in blotch flag
    if(sum(left_motion)*sum(right_motion)~=0);
        blotch_flag(row(i),col(i),fr(i)) = 0;
    end
end

disp('dialating blotches area...')
%dialation of blotch flag
for i = 1:d-2
    blotch_flag(:,:,i)=bwmorph(blotch_flag(:,:,i),'thicken',1);
end
 
disp('fixing blotches...')
%again get row,col,frame index in multiple dimensions
[row,col,fr] = ind2sub(size(blotch_flag), find(blotch_flag==1)); 

%1. fix the blotch in the second frame
index = find(fr==1);
for i = 1:length(index)
    current_frame = 2;
    previous_pixel1 = mov(row(index(i)),col(index(i)),current_frame-1);
    next_pixel1 = mov(row(index(i)),col(index(i)),current_frame+1)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))+1));
    next_pixel2 = mov(row(index(i)),col(index(i)),current_frame+2)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))+2));
    pixels = [previous_pixel1,next_pixel1,next_pixel2];
    mov(row(index(i)),col(index(i)),current_frame) =mean(pixels(pixels~=0));
end

%2. fix the blotch in the third frame
index = find(fr==2);
for i = 1:length(index)
    current_frame = 3;
    previous_pixel2 = mov(row(index(i)),col(index(i)),current_frame-2);
    previous_pixel1 = mov(row(index(i)),col(index(i)),current_frame-1)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))-1));
    next_pixel1 = mov(row(index(i)),col(index(i)),current_frame+1)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))+1));
    next_pixel2 = mov(row(index(i)),col(index(i)),current_frame+2)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))+2));
    pixels = [previous_pixel1,previous_pixel2,next_pixel1,next_pixel2];
    mov(row(index(i)),col(index(i)),current_frame) =mean(pixels(pixels~=0));
end

%3. fix the blotch in the end-1 frame
index = find(fr==d-2);
for i = 1:length(index)
    current_frame = d-1;
    previous_pixel2 = mov(row(index(i)),col(index(i)),current_frame-2)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))-2));
    previous_pixel1 = mov(row(index(i)),col(index(i)),current_frame-1)*(1-blotch_flag(row(index(i)),col(i),fr(index(i))-1));
    next_pixel1 = mov(row(index(i)),col(index(i)),current_frame+1);
    pixels = [previous_pixel1,previous_pixel2,next_pixel1];
    mov(row(index(i)),col(index(i)),current_frame) =mean(pixels(pixels~=0));
end

%4. fix the blotch in the end-2 frame
index = find(fr==d-3);
for i = 1:length(index)
    current_frame = d-2;
    previous_pixel1 = mov(row(index(i)),col(index(i)),current_frame-1)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))-1));
    previous_pixel2 = mov(row(index(i)),col(index(i)),current_frame-2)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))-2));
    next_pixel1 = mov(row(index(i)),col(index(i)),current_frame+1)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))+1));
    next_pixel2 = mov(row(index(i)),col(index(i)),current_frame+2);
    pixels = [previous_pixel1,previous_pixel2,next_pixel1];
    mov(row(index(i)),col(index(i)),current_frame) =mean(pixels(pixels~=0));
end

%5. fix the blotch in the rest frames
index = find(fr~=d-2 & fr~=d-3 & fr~=1 & fr~=2);
index_length = length(index);
for i = 1:index_length
    current_frame = fr(index(i))+1;
    previous_pixel1 = mov(row(index(i)),col(index(i)),current_frame-1)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))-1));
    previous_pixel2 = mov(row(index(i)),col(index(i)),current_frame-2)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))-2));
    next_pixel1 = mov(row(index(i)),col(index(i)),current_frame+1)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))+1));
    next_pixel2 = mov(row(index(i)),col(index(i)),current_frame+2)*(1-blotch_flag(row(index(i)),col(index(i)),fr(index(i))+2));
    pixels = [previous_pixel1,previous_pixel2,next_pixel1,next_pixel2];
    mov(row(index(i)),col(index(i)),current_frame) =mean(pixels(pixels~=0));
end

end
