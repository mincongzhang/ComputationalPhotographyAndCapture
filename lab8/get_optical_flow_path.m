function optical_flow_path = get_optical_flow_path(frame_sequence,frame_num,x_start,y_start)

    optical_flow_path = zeros(frame_num,2);
    x_index = x_start;
    y_index = y_start;
    optical_flow_path(1,1) = x_index;
    optical_flow_path(1,2) = y_index;

    for i = 1:frame_num-1
        [VX,VY] = get_optical_flow(frame_sequence(:,:,i),frame_sequence(:,:,i+1));
        x_index = x_index + VX(round(y_index),round(x_index));
        y_index = y_index + VY(round(y_index),round(x_index));
        optical_flow_path(i+1,1) = x_index;
        optical_flow_path(i+1,2) = y_index;
        
        disp(['optical flow path cumputing: frame ' num2str(i+1)])
    end

    save('optical_flow_path.mat','optical_flow_path','x_start','y_start');
end