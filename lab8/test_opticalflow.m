clc
clear 
close all

frame_num = 72;
start_frame = 1;


%load frames
if(exist('gjbLookAtTargets.mat','file')==2)
    load('gjbLookAtTargets.mat');
else
    M = load_sequence('./gjbLookAtTargets','small_', 1, frame_num, 4, 'jpg');
    save('gjbLookAtTargets.mat','M');
end

start_frame_file = imread(['./gjbLookAtTargets/small_000',num2str(start_frame),'.jpg']);
imshow(start_frame_file); title('Choose start position'); hold on;
[x_start y_start] = ginput(1);

actual_pathX = zeros(frame_num,1);
actual_pathY = zeros(frame_num,1);
actual_pathX(1,1) = x_start;
actual_pathY(1,1) = y_start;

for i = 2:frame_num
    [VX VY] = get_optical_flow(M(:,:,i-1),M(:,:,i));
    x_previous = actual_pathX(i-1);
    y_previous = actual_pathY(i-1);
    actual_pathX(i) = x_previous+VX(round(y_previous),round(x_previous));
    actual_pathY(i) = y_previous+VY(round(y_previous),round(x_previous));
end

    %plot trajectory
    plot(actual_pathX,actual_pathY,'r');hold on;