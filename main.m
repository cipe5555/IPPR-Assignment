% Function to process and identify defects
function gloves_defect_detection(image_path)

    % Read in the images
    img = imread('img6.jpg');

    % Convert the image to grayscale
    grayImage = rgb2gray(img);

    % Edge detection with sobel
    h=fspecial('sobel');
    img_sobel = imfilter(grayImage, h);

    % Apply a threshold to get a binary image
    thresholdValue = 0.40; % threshold
    bw = im2bw(grayImage, thresholdValue);
    %bw = imbinarize(grayImage);
    bw = ~bw;

    
    % Use morphological operations to remove noise and fill holes
    cleanedImage = bwareaopen(bw, 50); % Remove small objects
    filledImage = imfill(bw, 'holes'); % Fill holes
    
    img_sub = filledImage & -cleanedImage
    imshow(img_sub);

    % Label the defects
    labeled_defects = bwlabel(img_sub);

     % Measure properties of image regions
    stats = regionprops(labeled_defects, 'Area', 'Centroid');
    
    % Show the original image
    imshow(img);
    hold on;
    
    % Loop through each defect and annotate them
    for i = 1:numel(stats)
        defect_area = stats(i).Area;
        centroid = stats(i).Centroid;
        text(centroid(1), centroid(2), sprintf('Defect %d: Area = %d', i, defect_area), 'Color', 'r');
    end
    hold off
 
end