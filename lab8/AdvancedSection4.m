clc
clear
close all
addpath('mex');

%Default Settings
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
    end_frame = find(diff == min(diff));
    
    %get shortest path
    [dist,path_temp,pred] = graphshortestpath(DG,start_frame,end_frame);
    start_frame = end_frame;
    
    %add to path
    path = [path path_temp];
end

%%
%Multi-node interpolation: find the other two node in the last optical_flow_path
%get frame index
diff(diff == min(diff)) = inf;
node1_index = find(diff == min(diff));
diff(diff == min(diff)) = inf;
node2_index = find(diff == min(diff));

%get frames
if(end_frame<10)
    end_idx = ['./gjbLookAtTargets/small_000',num2str(end_frame),'.jpg'];
else
    end_idx = ['./gjbLookAtTargets/small_00',num2str(end_frame),'.jpg'];
end
if(node1_index<10)
    node1_idx = ['./gjbLookAtTargets/small_000',num2str(node1_index),'.jpg'];
else
    node1_idx = ['./gjbLookAtTargets/small_00',num2str(node1_index),'.jpg'];
end
if(node2_index<10)
    node2_idx = ['./gjbLookAtTargets/small_000',num2str(node2_index),'.jpg'];
else
    node2_idx = ['./gjbLookAtTargets/small_00',num2str(node2_index),'.jpg'];
end

end_img = im2double(imread(end_idx));
node1_img = im2double(imread(node1_idx));
node2_img = im2double(imread(node2_idx));

[VX1,VY1] = get_optical_flow(end_img,node1_img);
[VX2,VY2] = get_optical_flow(end_img,node2_img);

%Synthesize new vector
synthesized_VX = VX1+VX2;
synthesized_VY = VY1+VY2;

path_length = length(path);
%get actual path
actual_pathX = zeros(path_length,1);
actual_pathY = zeros(path_length,1);
for i = 1:path_length
    actual_pathX(i) = optical_flow_path(path(i),1);
    actual_pathY(i) = optical_flow_path(path(i),2);
end

%get synthesized path
synthesized_pathX = zeros(2,1);
synthesized_pathY = zeros(2,1);
synthesized_pathX(1) = actual_pathX(end);
synthesized_pathY(1) = actual_pathY(end);

%get direction of syhthesized path
%1. synthesized vector
s_x = synthesized_VX(ceil(actual_pathY(end)),ceil(actual_pathX(end)));
s_y = synthesized_VY(ceil(actual_pathY(end)),ceil(actual_pathX(end)));
%2. desired vector
d_x = desired_pathX(end)-actual_pathX(end);
d_y = desired_pathY(end)-actual_pathY(end);

% change into same direction
if(s_x*d_x>=0)   % same direction
    synthesized_pathX(2) = actual_pathX(end) + s_x;
    synthesized_VX = synthesized_VX;
else             % opposite direction
    synthesized_pathX(2) = actual_pathX(end) - s_x;
    synthesized_VX = -synthesized_VX;
end

if(s_y*d_y>=0)   % same direction
    synthesized_pathY(2) = actual_pathY(end) + s_y;
    synthesized_VY = synthesized_VY;
else             % opposite direction
    synthesized_pathY(2) = actual_pathY(end) - s_y;
    synthesized_VY = -synthesized_VY;
end


%Interpolate according to optical flow
% synthesized_interpolate_num = max(max(synthesized_VX(:)),max(synthesized_VY(:)));
synthesized_interpolate_num = 10;
[row,col,dim] = size(end_img);

synthesized_interpolate_frames = zeros(row,col,dim,synthesized_interpolate_num);

%initial with end_img to reduce artifact
for n = 1:synthesized_interpolate_num
    synthesized_interpolate_frames(:,:,:,n) = end_img;
end

%mix interpolating between start frame and end frame
for n = 1:synthesized_interpolate_num
    for i = 1:row
        for j = 1:col
            for p = 1:dim
                %1. from start frame
                %backward mapping to prevent holes in result image
                x = j-synthesized_VX(i,j)/synthesized_interpolate_num*n; % col
                y = i-synthesized_VY(i,j)/synthesized_interpolate_num*n; % row
                x = round(x);
                y = round(y);
                if(x<=col && x>0 && y<=row && y>0)
                    synthesized_interpolate_frames(i,j,p,n) = end_img(y,x,p);
                end
            end
        end
    end
end

%%
%Output result
[row,col] = size(M(:,:,1));
gif_volume = zeros(row,col,3,1);

output_id = 1;
for i = 1:path_length-1

    if(path(i)<10)
        sourcefile = ['./gjbLookAtTargets/small_000',num2str(path(i)),'.jpg'];
    else
        sourcefile = ['./gjbLookAtTargets/small_00',num2str(path(i)),'.jpg'];
    end
    
    if(path(i+1)<10)
        next_sourcefile = ['./gjbLookAtTargets/small_000',num2str(path(i+1)),'.jpg'];
    else
        next_sourcefile = ['./gjbLookAtTargets/small_00',num2str(path(i+1)),'.jpg'];
    end
    
    I1 = imread(sourcefile);
    I2 = imread(next_sourcefile);
    
    %interpolation
    frames = frame_interpolate(I1,I2);
    frames_length = size(frames,4);
    
    %write output
    for f = 1:frames_length
        if(output_id<10)
            new_filename = ['AdvancedSection4_000',num2str(output_id)];
        elseif(output_id<100)
            new_filename = ['AdvancedSection4_00',num2str(output_id)];
        elseif(output_id<1000)
            new_filename = ['AdvancedSection4_0',num2str(output_id)];
        end
        
        imwrite(frames(:,:,:,f),fullfile(['./output/AdvancedSection4/',new_filename, '.jpg']),'quality',100);
        imshow(frames(:,:,:,f));hold on; drawnow;
        
        %plot trajectory
        plot(desired_pathX,desired_pathY);hold on;drawnow;
        plot(actual_pathX,actual_pathY,'r');hold on; drawnow;
        
        %get gif frame
        gif_volume(:,:,:,output_id) = frames(:,:,:,f);
        output_id = output_id+1;
        disp(['output frame:' num2str(output_id)]);
    end
end

%Add synthesized_interpolate_frames
for f = 1:synthesized_interpolate_num
    if(output_id<10)
        new_filename = ['AdvancedSection4synthesized_000',num2str(output_id)];
    elseif(output_id<100)
        new_filename = ['AdvancedSection4synthesized_00',num2str(output_id)];
    elseif(output_id<1000)
        new_filename = ['AdvancedSection4synthesized_0',num2str(output_id)];
    end
    
    imwrite(synthesized_interpolate_frames(:,:,:,f),fullfile(['./output/AdvancedSection4/',new_filename, '.jpg']),'quality',100);
    imshow(synthesized_interpolate_frames(:,:,:,f));hold on; drawnow;
    
    %plot trajectory
    plot(desired_pathX,desired_pathY);hold on;drawnow;
    plot(actual_pathX,actual_pathY,'r');hold on; drawnow;
    plot(synthesized_pathX,synthesized_pathY,'g');hold on; drawnow;
    
    %get gif frame
    gif_volume(:,:,:,output_id) = synthesized_interpolate_frames(:,:,:,f);
    output_id = output_id+1;
    disp(['output frame:' num2str(output_id)]);
end

%write gif
frame2gif(gif_volume,fullfile('output/AdvancedSection4/','AdvancedSection4.gif'));
