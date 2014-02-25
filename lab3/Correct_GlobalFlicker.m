function mov = Correct_GlobalFlicker(mov,d,scenecut_index);
%This function finds the big change of the histogram between frames,
%and considers these frames as global flicker. 
%Ignoring the scene cut and very large histogram change that maybe caused
%by moving objects, the remaining big changes between frames are considered
%as global flicker.
%Then it calculate the mean pixel values of the two frames, and recover the 
%second frame by adding the difference back.

flicker_thresh = 5*10^4;

%calculate histogram difference
sum_of_diff = zeros(1,d-1);

for i = 1:d-1
    counts1 = imhist(mov(:,:,i));
    counts2 = imhist(mov(:,:,i+1));
    diff = counts2-counts1;
    sum_of_diff(i) = sum(abs(diff));
end

figure,plot(sum_of_diff);title('histogram difference between frames (for the correction of global flicker)');

sorting = sort(sum_of_diff);

%ignore very large histogram change
index = find(sum_of_diff>flicker_thresh & sum_of_diff<=sorting(end-2));

%ignore the first frame and scenecut frames
index(index==1) = [];
for i = 1:length(scenecut_index)
    index(index==scenecut_index(i)) = [];
end

index_length = length(index);
for i = 1:index_length
    %histogram mapping 
%     [counts1 ~] = imhist(mov(:,:,index(i)-1));
%     [counts2 ~] = imhist(mov(:,:,index(i)));
%     mov(:,:,index(i)) = histeq(mov(:,:,index(i)),counts1);
%     
%     [counts2 ~] = imhist(mov(:,:,index(i)));
%     [counts3 ~] = imhist(mov(:,:,index(i)+1));
%     mov(:,:,index(i)+1) = histeq(mov(:,:,index(i)+1),counts2);
    
%     %mean pixels value adding
    diff = mean2(mov(:,:,index(i)-1)) - mean2(mov(:,:,index(i)));
    mov(:,:,index(i)) = mov(:,:,index(i)) + diff;
    
    diff = mean2(mov(:,:,index(i))) - mean2(mov(:,:,index(i)+1));
    mov(:,:,index(i)+1) = mov(:,:,index(i)+1) + diff;

    disp(['handling ',num2str(round(i/index_length*100)),'%']);
end

end