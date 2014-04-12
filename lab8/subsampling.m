count = 1;
for i = 0:1:71
    if(i<10)
        filename = ['./pictures/gjbLookAtTarget_000' num2str(i) '.jpg'];
    else
        filename = ['./pictures/gjbLookAtTarget_00' num2str(i) '.jpg'];
    end
    
    if(count<10)
        new_filename = ['small_000' num2str(count)];
    else
        new_filename = ['small_00' num2str(count)];
    end
    
    I = imread(filename);
    I = imresize(I,0.25);
    imwrite(I,fullfile(['./pictures/',new_filename '.jpg']),'quality',100);
    
    count = count+1;
 end
