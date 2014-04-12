clc
clear
close all
addpath('mex');

%Default Settings
%look at positions
position_num = 5;
start_frame = 1;
frame_num = 135;

%load frames
if(exist('shaun.mat','file')==2)
    load('shaun.mat');
else
    M = load_sequence('./shaun','shaun', 1, frame_num, 3, 'jpg');
    save('shaun.mat','M');
end
disp('load sequence finished');

if(start_frame<10)
    start_frame_file = imread(['./shaun/shaun00',num2str(start_frame),'.jpg']);
elseif(start_frame>10 && start_frame<100)
    start_frame_file = imread(['./shaun/shaun0',num2str(start_frame),'.jpg']);
elseif(start_frame>100)
    start_frame_file = imread(['./shaun/shaun',num2str(start_frame),'.jpg']);
end

%%
%Get DG matrix
if(exist('buildDGmatrix_shaun.mat','file')==2)
    load('buildDGmatrix_shaun.mat');
else
    %build DG matrix
    disp('building DG matrix');
    DG = buildDGmatrix(M);
end

%%
%Get original path from optical flow
if(exist('optical_flow_path_shaun.mat','file')==2)
    load('optical_flow_path_shaun.mat');
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
        sourcefile = ['./shaun/shaun00',num2str(path(i)),'.jpg'];
        new_filename = ['AdvancedSection2_00',num2str(i)];
    elseif(path(i)>10 && path(i)<100)
        sourcefile = ['./shaun/shaun0',num2str(path(i)),'.jpg'];
        new_filename = ['AdvancedSection2_0',num2str(i)];
    elseif(path(i)>100)
        sourcefile = ['./shaun/shaun',num2str(path(i)),'.jpg'];
        new_filename = ['AdvancedSection2_',num2str(i)];
    end
    
    I = imread(sourcefile);
    imshow(I);
    %plot trajectory
    plot(desired_pathX,desired_pathY);hold on;
    plot(actual_pathX,actual_pathY,'r');hold on;
    
    %imwrite(I,fullfile(['./output/AdvancedSection2/',new_filename, '.jpg']),'quality',100);
    
    %create gif matrix
    gif_vloume(:,:,:,i) = I; 
    pause(0.1);
end

%write gif
%frame2gif(gif_vloume,fullfile('output/AdvancedSection2/','AdvancedSection2.gif'));
