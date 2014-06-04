function lab1
    close all;
    
    % first define some parameters for our movie
    frameSize = [200, 200]; % height and width of the output movie
    fps = 30; % frames per second
    speed = [3, 3]; % how quickly the camera moves in each direction (y, x)
    nFrames = 200; % number of frames
    
    % load the big source image and read some of its parameters
    fileName = 'image1.jpg';
    image = imread(fileName);
    [height, width, depth] = size(image);
    imgInfo = imfinfo(fileName);
    
    % create the frames
    x = 1;
    y = 1;
    for fr = 1:nFrames
        % extract subImage from the current coordinates
        subImage = image(y:y+frameSize(1)-1, x:x+frameSize(2)-1, :);
        % paint in the text
        imshow(subImage);
        hold on;
        text(25, 10, imgInfo.DateTime, 'FontSize', 12, 'FontWeight', 'demi');
        hold off;
        % save as a movie frame
        M(fr) = getframe(gca);
        
        % check if the next step will be a valid coordinate and reverse
        % the movement direction if neccesary
        if (y + frameSize(1) + speed(1) > height) || (y + speed(1) < 1)
            speed(1) = -speed(1);
        end
        
        if (x + frameSize(2) + speed(2) > width)  || (x + speed(2) < 1)
            speed(2) = -speed(2);
        end
        
        % modify the coords for the next iteration
        x = x + speed(2);
        y = y + speed(1);
    end
    % export the movie matrix into an AVI file
    movie2avi(M, 'film.avi', 'compression', 'none', 'FPS', fps);
end