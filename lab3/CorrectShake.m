function mov = CorrectShake(mov,m,n,scenecut_index)
%This function uses the results of edge detection of two frames to calculate 
%their 2D cross-correlation. The location of the maximal correlation in 2D 
%can be seen as the feature position, representing the whole frame¡¯s location.

%For the first frame calculate the 2D cross-correlation with itself as the 
%reference location. Then calculate the 2D cross-correlation of the second 
%frame and the first frame. 

%By comparing the result location with the reference location,whether the 
%second frame has shaken can be detected. Afterwards the potential camera shake 
%can be recovered by moving the second frame to the right position.


shake_thresh = 7;

end_index = scenecut_index(end);

row = zeros(1,end_index);
col = zeros(1,end_index);

for i = 1:end_index
    frame_edge(:,:,i) = edge(mov(:,:,i),'sobel',0.05);
end
frame_edge = double(frame_edge);

%reference frame
[row(1) col(1)] = detect_shake(frame_edge(:,:,1),frame_edge(:,:,1));


for i = 2:end_index
    [row(i) col(i)] = detect_shake(frame_edge(:,:,i),frame_edge(:,:,i-1));
    %if the location change too big, do not change
    if(abs(row(i)-row(i-1))<shake_thresh | abs(col(i)-col(i-1))<shake_thresh)
        mov(:,:,i) = recover_shake(mov(:,:,i),m,n,row(i)-row(i-1),col(i)-col(i-1));
        frame_edge(:,:,i) = recover_shake(frame_edge(:,:,i),m,n,row(i)-row(i-1),col(i)-col(i-1));
    end
    
    %take recovered frame as reference for next frame
    [row(i) col(i)] = detect_shake(frame_edge(:,:,i),frame_edge(:,:,i));
    
    disp(['handling ',num2str(i/end_index*100),'%']);
end

end

function [row col] = detect_shake(E1,E2)

% A = conv2(E1,E2,'same');
A = xcorr2(E1,E2);
[row col] = find(A==(max(A(:))));

%in case there are multiple row or col index
row = round(median(row));
col = round(median(col));
end

function R = recover_shake(I,m,n,row_move,col_move)

R = zeros(m,n);
% for i = 1:m
%     for j = 1:n
%         
%     inside = (i+row_move)>0 & (i+row_move)<=m & (j+col_move)>0 & (j+col_move)<=n;
%     if(inside)
%         R(i,j) = I(i+row_move,j+col_move);
%     end
%     
%     end
% end

%5 time faster method
if(row_move<=0)
    if(col_move<=0) % row_move<0 col_move<0
        R(1-row_move:end,1-col_move:end) = I(1:end+row_move,1:end+col_move);
    else            % row_move<0 col_move>0
        R(1-row_move:end,1:end-col_move) = I(1:end+row_move,col_move+1:end);
    end
else
    if(col_move<=0) % row_move>0 col_move<0
        R(1:end-row_move,1-col_move:end) = I(row_move+1:end,1:end+col_move);
    else            % row_move>0 col_move>0
        R(1:end-row_move,1:end-col_move) = I(row_move+1:end,col_move+1:end);
    end
end

end
