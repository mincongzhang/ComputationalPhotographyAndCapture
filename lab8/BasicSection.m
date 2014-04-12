clc
clear
close all
addpath('mex');

%look at positions
position_num = 5;
start_frame = 1;
frame_num = 72;

%load frames
if(exist('gjbLookAtTargets.mat','file')==2)
    load('gjbLookAtTargets.mat');
else
    M = load_sequence('./gjbLookAtTargets','small_', 1, frame_num, 4, 'jpg');
    save('gjbLookAtTargets.mat','M');
end

if(start_frame<10)
    start_frame_file = imread(['./gjbLookAtTargets/small_000',num2str(start_frame),'.jpg']);
else
    start_frame_file = imread(['./gjbLookAtTargets/small_00',num2str(start_frame),'.jpg']);
end
%%
%build DG matrix
if(exist('buildDGmatrix.mat','file')==2)
    load('buildDGmatrix.mat');
else
    DG = buildDGmatrix(M);
end

%%
imshow(start_frame_file); title('Choose start position');
[x_start y_start] = ginput(1);

imshow(start_frame_file); title('Choose look at positions');
[desired_pathX desired_pathY] = ginput(position_num);
actual_pathX = zeros(position_num+1,1);
actual_pathY = zeros(position_num+1,1);
actual_pathX(1,1) = x_start;
actual_pathY(1,1) = y_start;

%%
%Output
path = [];
for d = 1:position_num
    [pathend_coordinates Paths] = calculate_position_index(M,DG,start_frame,x_start,y_start,frame_num);

    %get look at direction
    diff = ones(1,frame_num).*inf;

    for f = 1:frame_num
        diff(f) = sqrt((pathend_coordinates(1,f)-desired_pathX(d))^2 + (pathend_coordinates(2,f)-desired_pathY(d))^2);
    end

    %get frame index of pathend
    pathend_idx = find(diff == min(diff));
    path = [path Paths{pathend_idx}];

    %update the start position and start frame
    x_start = pathend_coordinates(1,pathend_idx);
    y_start = pathend_coordinates(2,pathend_idx);
    start_frame = pathend_idx;
end

path_length = length(path);
%get actual trajectory
for i = 2:path_length
    [VX VY] = get_optical_flow(M(:,:,path(i-1)),M(:,:,path(i)));
    x_previous = actual_pathX(i-1);
    y_previous = actual_pathY(i-1);
    actual_pathX(i) = x_previous+VX(round(y_previous),round(x_previous));
    actual_pathY(i) = y_previous+VY(round(y_previous),round(x_previous));
end

for i = 1:path_length
    if(path(i)<10)
        sourcefile = ['./gjbLookAtTargets/small_000',num2str(path(i)),'.jpg'];
        new_filename = ['BasicSection_000',num2str(i)];
    else
        sourcefile = ['./gjbLookAtTargets/small_00',num2str(path(i)),'.jpg'];
        new_filename = ['BasicSection_00',num2str(i)];
    end
    
    I = imread(sourcefile);
    imshow(I); hold on;
    %plot trajectory
    plot(desired_pathX,desired_pathY);hold on;
    plot(actual_pathX,actual_pathY,'r');hold on;

    imwrite(I,fullfile(['./output/BasicSection/',new_filename, '.jpg']),'quality',100);
    
    %create gif matrix
    gif_vloume(:,:,:,i) = I; 
    pause(0.1);
end

%write gif
frame2gif(gif_vloume,fullfile('output/BasicSection/','BasicSection.gif'));