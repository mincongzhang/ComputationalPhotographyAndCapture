function result = labs2

% First calibrate the cameras, get the intrinsics K, and the extrinsics R1,
% T1, R2, T2.
% Note: the matrices returned by the calibration process define the
% relative position of the checkerboard wrt the camera. Therefore, they are
% the matrices that go from world to camera coordinate.

% Copy also in this script the positions of the points you chose (you don't
% want to do that every time you run the script so do it beforehand).

%%%%%%%%%%%% 

phi_x = 2532.90500;
phi_y = 2540.77599;
delta_x = 1630.16425;
delta_y = 1133.42482;

K = [phi_x    0    delta_x;
     0      phi_y  delta_y;
     0        0       1    ];
 
R1 = [ 0.112802 	 0.993609 	 -0.004113
       0.322720 	 -0.040552 	 -0.945626
      -0.939749 	 0.105341 	 -0.325231 ];
T1 = [ 224.605902 	 347.083888 	 1356.928681 ];
R2 = [ -0.487538 	 0.873056 	 0.008961
        0.241658 	 0.144796 	 -0.959497
       -0.838992 	 -0.465626 	 -0.281575 ];
T2 = [ -434.195694 	 307.697769 	 1166.091887 ];

 % Now do crazy stuff and reconstruct the 3D skeleton
 imshow('view1.jpg');
 [X1,Y1] = ginput(5);
 
  imshow('view2.jpg');
 [X2,Y2] = ginput(5);

M_camera_to_world

%%%%%%%%%%%% 

% Plot everything

figure

grid off
axis equal
axis([-1000 1000 -1000 2500 -3000 2500])

% use joinPoint method to draw your skeleton
% here we draw a cube to see how it works
P1 = [0.0 0.0 0.0];
P2 = [500.0 0.0 0.0];
P3 = [0.0 500.0 0.0];
P4 = [0.0 0.0 500.0];
P5 = [500.0 500.0 0.0];
P6 = [500.0 0.0 500.0];
P7 = [0.0 500.0 500.0];
P8 = [500.0 500.0 500.0];

joinPoints(P1, P2)
joinPoints(P1, P3)
joinPoints(P1, P4)
joinPoints(P2, P5)
joinPoints(P2, P6)
joinPoints(P3, P5)
joinPoints(P3, P7)
joinPoints(P4, P6)
joinPoints(P4, P7)
joinPoints(P5, P8)
joinPoints(P6, P8)
joinPoints(P7, P8)

% Draw cam 1
% You need to compute the transformation matrix to go from camera to world
% coordinate
% drawCamera(M1_c_to_w)

% Draw cam 2
% You need to compute the transformation matrix to go from camera to world
% coordinate
% drawCamera(M2_c_to_w)

% Checkerboard
% drawCheckerboard

% the end
result = 0;

end

% Use the matrix M_camera_to_world to position the camera
% correctly in the world
function void = drawCamera(M_camera_to_world)
    C_1 =  [0.0; 0.0; 0.0; 1.0];
    C_2 =  [50.0; 50.0; 100.0; 1.0];
    C_3 =  [50.0; -50.0; 100.0; 1.0];
    C_4 =  [-50.0; 50.0; 100.0; 1.0];
    C_5 =  [-50.0; -50.0; 100.0; 1.0];

    C_1_w = M_camera_to_world*C_1;
    C_2_w = M_camera_to_world*C_2;
    C_3_w = M_camera_to_world*C_3;
    C_4_w = M_camera_to_world*C_4;
    C_5_w = M_camera_to_world*C_5;

    C_1_w = C_1_w/C_1_w(end);
    C_2_w = C_2_w/C_2_w(end);
    C_3_w = C_3_w/C_3_w(end);
    C_4_w = C_4_w/C_4_w(end);
    C_5_w = C_5_w/C_5_w(end);

    joinPoints(C_1_w, C_2_w);
    joinPoints(C_1_w, C_3_w);
    joinPoints(C_1_w, C_4_w);
    joinPoints(C_1_w, C_5_w);
    joinPoints(C_2_w, C_3_w);
    joinPoints(C_2_w, C_4_w);
    joinPoints(C_4_w, C_5_w);
    joinPoints(C_5_w, C_3_w);
end

% Draw the checkerboard
function void = drawCheckerboard
    C_1 =  [0.0; 0.0; 0.0; 1.0];
    C_2 =  [196.0; 0.0; 0.0; 1.0];
    C_3 =  [196.0; 140.0; 0.0; 1.0];
    C_4 =  [0.0; 140.0; 0.0; 1.0];

    joinPoints(C_1, C_2);
    joinPoints(C_2, C_3);
    joinPoints(C_3, C_4);
    joinPoints(C_4, C_1);
end

% Draw the line between two points
function void = joinPoints(P1, P2)
    line( [P1(1) P2(1)], [P1(2) P2(2)], [P1(3) P2(3)])
    void = 0;
end