function mov = CorrectVertical(mov,d,scenecut_index)
%This function uses median filters to remove vertical artifacts.
%It uses a mask to save the details of edges, and add it back to
%reduce the blurred result. 

start_index =  scenecut_index(end);
for i = start_index:d
  med = medfilt2(mov(:,:,i),[1,7]);
  mask = (imsharpen(med,'Radius',2,'Amount',1)-mov(:,:,i))>5;
  mask = uint8(mask);
  frame_mask = mask.*mov(:,:,i);
  %add details back to blurred result
  enhanced = frame_mask+(1-mask).*med; 
  %sharpen and blur again to reduce vertical artifacts
  mov(:,:,i) = imsharpen(enhanced);
  mov(:,:,i) = medfilt2(mov(:,:,i),[1,3]);
end
