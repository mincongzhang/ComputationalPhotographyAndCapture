clc
clear
close all
addpath('mex');

%Default Settings
%look at positions
position_num = 5;
frame_num = 72;
start_frame = 1;

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
%Get DG matrix
if(exist('buildDGmatrix.mat','file')==2)
    load('buildDGmatrix.mat');
else
    %build DG matrix
    DG = buildDGmatrix(M);
end

%%
%Get original path from optical flow
if(exist('optical_flow_path.mat','file')==2)
    load('optical_flow_path.mat');
else
    %get optical flow path
    imshow(start_frame_file);title('Choose start position');
    [x_start y_start] = ginput(1);
    optical_flow_path = get_optical_flow_path(M,frame_num,x_start,y_start);
end
% plot(optical_flow_path(:,1),optical_flow_path(:,2));

%%
%get look at position
imshow(start_frame_file);title('Choose look at position');hold on;
[desired_pathX desired_pathY] = ginput(position_num);
%plot desired path
plot(desired_pathX,desired_pathY);hold on;

optical_flow_path_length = size(optical_flow_path,1);

%Find path
path = [];
for p = 1:position_num
    %get cloest point from the input end coordinates
    diff = ones(optical_flow_path_length,1).*inf;
    for i = 1:optical_flow_path_length
        diff(i) = (desired_pathX(p)-optical_flow_path(i,1))^2 + (desired_pathY(p)-optical_flow_path(i,2))^2;
    end
    frame_index = find(diff == min(diff));
   
    %get shortest path
    [dist,path_temp,pred] = graphshortestpath(DG,start_frame,frame_index);
    start_frame = frame_index;
    
    %add to path
    path = [path path_temp];
end

%%
%Output result
path_length = length(path);
[row col] = size(M(:,:,1));
gif_volume = zeros(row,col,3,path_length);

%get actual path
actual_pathX = zeros(path_length,1);
actual_pathY = zeros(path_length,1);
for i = 1:path_length
    actual_pathX(i) = optical_flow_path(path(i),1);
    actual_pathY(i) = optical_flow_path(path(i),2);
end

for i = 1:path_length
    if(path(i)<10)
        sourcefile = ['./gjbLookAtTargets/small_000',num2str(path(i)),'.jpg'];
        new_filename = ['AdvancedSection_000',num2str(i)];
    else
        sourcefile = ['./gjbLookAtTargets/small_00',num2str(path(i)),'.jpg'];
        new_filename = ['AdvancedSection_00',num2str(i)];
    end
    I = imread(sourcefile);
    imshow(I);
    %plot trajectory
    plot(desired_pathX,desired_pathY);hold on;
    plot(actual_pathX,actual_pathY,'r');hold on;
    
    imwrite(I,fullfile(['./output/AdvancedSection1/',new_filename, '.jpg']),'quality',100);
    
    %create gif matrix
    gif_vloume(:,:,:,i) = I; 
    pause(0.1);
end

%write gif
frame2gif(gif_vloume,fullfile('output/AdvancedSection1/','AdvancedSection.gif'));
