function [pathend_coordinates Paths] = calculate_position_index(M,DG,start_frame,x_start,y_start,frame_num)
    addpath('mex');
    
    %choose start frame and start point
    %default start frame is set as the first frame, start point(points) can be
    %chosen as one eye's position
    if(length(who('start_frame'))==0)
        start_frame = 1;
    end

    %initial index array as infinite value, 
    %keeping the end position coordinates
    pathend_coordinates = ones(2,frame_num).*inf;
    
    %initial a cell for saving each path
    Paths = cell(frame_num,1);

    for i = 1:frame_num
        if(i~=start_frame)
            disp(['frame number:',num2str(i)]);
            [dist,path,pred] = graphshortestpath(DG,start_frame,i);
            Paths{i} = path;
            
            x_index = x_start;
            y_index = y_start;
            path_length = length(path);
            for j=1:path_length-1
                [VX VY] = get_optical_flow(M(:,:,path(j)),M(:,:,path(j+1)));
                x_index = x_index + VX(round(y_index),round(x_index));
                y_index = y_index + VY(round(y_index),round(x_index));
            end

            %final coordinates
            pathend_coordinates(1,i) = x_index;
            pathend_coordinates(2,i) = y_index;
        end
    end

    %save('pathend_coordinates.mat','pathend_coordinates','Paths');
end