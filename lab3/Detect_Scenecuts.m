function [sum_of_diff index] = Detect_Scenecuts(mov,d)
%This function calculates the difference of pixels between frames. If there is a big
%change, it considers the relevant frame as a scenecut.

%calculate the difference between 2 frames
mov1 = mov;
mov2 = mov;
mov1(:,:,end) = [];
mov2(:,:,1) = [];


diff = imabsdiff(mov2,mov1);

sum_of_diff = sum(sum(diff,1),2);
sum_of_diff = sum_of_diff(:);

figure,plot(1:d-1,sum_of_diff);title('Sum of difference pixel values between frames');

sorting = sort(sum_of_diff);
index = find(sum_of_diff>=sorting(end-1));
end