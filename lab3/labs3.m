function output = labs3(path, prefix, first, last, digits, suffix)

%
% Read a sequence of images and correct the film defects. This is the file 
% you have to fill for the coursework. Do not change the function 
% declaration, keep this skeleton. You are advised to create subfunctions.
% 
% Arguments:
%
% path: path of the files
% prefix: prefix of the filename
% first: first frame
% last: last frame
% digits: number of digits of the frame number
% suffix: suffix of the filename
%
% This should generate corrected images named [path]/corrected_[prefix][number].png
%
% Example:
%
% mov = labs3('../images','myimage', 0, 10, 4, 'png')
%   -> that will load and correct images from '../images/myimage0000.png' to '../images/myimage0010.png'
%   -> and export '../images/corrected_myimage0000.png' to '../images/corrected_myimage0010.png'
%

% Your code here
mov = load_sequence(path, prefix, first, last, digits, suffix);

%record m,n as row and column, d as the number of frames
[m,n,d] = size(mov);

% Detection of scene cuts
[frame_difference scenecut_index] = Detect_Scenecuts(mov,d);
disp('Detection of scene cuts finished ');
disp('press "space" to correct global flicker...')
pause
close all;

% Correction of global flicker
mov = Correct_GlobalFlicker(mov,d,scenecut_index);
disp('Correction of global flicker finished ');
disp('press "space" to correct blotches...')
pause
close all;

% Correction of blotches
mov = Correct_Blotch(mov,d);
disp('Correction of blotches finished ');
disp('press "space" to correct vertical artefacts...')
pause
close all;

% Correction of vertical artefacts
mov = CorrectVertical(mov,d,scenecut_index);
disp('Correction of vertical artefacts finished ');
disp('press "space" to correct camera shake...')
pause
close all;

%Correction of camera shake
mov = CorrectShake(mov,m,n,scenecut_index);
disp('Correction of vertical artefacts finished ');
disp('press "space" to save the output and generate the video...')
pause
close all;

%Save footage
disp('Saving...')
save_sequence(mov, './output', 'footage', 1, 4);

 
%make the video
disp('Generating the video...')
fps = 30; % frames per second
sceneNo = 1;
    
for fr = 1:d
    %paint in the text
    imshow(mov(:,:,fr));
    hold on;
    if(sum(scenecut_index==fr))
        sceneNo = sceneNo + 1;
    end
        text(25, 10, ['scene ' int2str(sceneNo)], 'FontSize', 12, 'FontWeight', 'demi','BackgroundColor',[.9 .9 .9]);
    hold off;
    
    % save as a movie frame
    M(fr) = getframe(gca);
end
    % export the movie matrix into an AVI file
    movie2avi(M, 'film.avi', 'compression', 'none', 'FPS', fps);

    disp('Generation of video finished ');
end
