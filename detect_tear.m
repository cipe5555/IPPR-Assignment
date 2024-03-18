close all;
clearvars;

img = imread('img9.jpg');

% Convert the image to HSV color space
img_hsv = rgb2hsv(img);

% Define lower and upper bounds for glove color in HSV space
glove_lower = [0,0,0] / 255; % Adjust these values according to your glove color and normalize bounds to the range [0, 1]
glove_upper = [255,120,255] / 255; % Adjust these values according to your glove color and normalize bounds to the range [0, 1]

% Create mask for glove color in HSV space
glove_mask = (img_hsv(:,:,1) >= glove_lower(1) & img_hsv(:,:,1) <= glove_upper(1)) & ...
       (img_hsv(:,:,2) >= glove_lower(2) & img_hsv(:,:,2) <= glove_upper(2)) & ...
       (img_hsv(:,:,3) >= glove_lower(3) & img_hsv(:,:,3) <= glove_upper(3));

% Extract glove region
glove_extracted = img_hsv;
glove_extracted(repmat(~glove_mask,[1 1 3])) = 0;

% Convert to binary mask
glove_binary = glove_extracted(:,:,1) > 0 | glove_extracted(:,:,2) > 0 | glove_extracted(:,:,3) > 0;
glove_binary = imcomplement(glove_binary);

% Perform morphological operations
se = strel('square', 3);
glove_binary = imerode(glove_binary, se);
glove_binary = imdilate(glove_binary, se);

% Find largest contour
[glove_contours, ~] = bwboundaries(glove_binary, 'noholes');

largest_contour = [];
largest_contour_area = -1;

for i = 1:length(glove_contours)
    current_contour = glove_contours{i};
    current_contour_area = polyarea(current_contour(:, 2), current_contour(:, 1));

    if current_contour_area > largest_contour_area
        largest_contour = current_contour;
        largest_contour_area = current_contour_area;
    end
end

% Create ROI bounding box
glove_bbox = [min(largest_contour(:, 2)), min(largest_contour(:, 1)), ...
              max(largest_contour(:, 2)) - min(largest_contour(:, 2)), ...
              max(largest_contour(:, 1)) - min(largest_contour(:, 1))];

% Crop ROI from original image
glove_roi = imcrop(img, glove_bbox);

threshhold = 130;
roi_mask = glove_roi(:,:,1) < threshhold;

fill_img = imfill(roi_mask, 'holes');

open_img = bwareaopen(fill_img, 100);

se = strel('disk', 5);
close_img = imclose(roi_mask, se);

boundaries = bwboundaries(close_img);

% Find the largest contour as the main glove contour
largestArea = 0;
largestIndex = 0;
for k = 1:length(boundaries)
    boundary = boundaries{k};
    % Calculate area of current contour
    area = size(boundary, 1);
    if area > largestArea
        largestArea = area;
        largestIndex = k;
    end
end

% Extract the main glove contour
main_glove_contour = boundaries{largestIndex};
min_area_threshold = 1000;

figure;
imshow(glove_roi);
hold on;
for k = 1:length(boundaries)
    boundary = boundaries{k};

    if size(boundary, 1) < size(main_glove_contour, 1)

        % Calculate centroid of the current contour
        centroid = mean(boundary);

        % Check if centroid is inside the main glove contour
        is_inside = inpolygon(centroid(1), centroid(2), main_glove_contour(:,1), main_glove_contour(:,2));

        if is_inside
            tearArea = polyarea(boundary(:,2), boundary(:,1));
            distances = sqrt(sum(bsxfun(@minus, boundary, centroid).^2, 2));

            if tearArea > min_area_threshold 
                tearBoundingBox = [min(boundary(:,2)), min(boundary(:,1)), ...
                                   max(boundary(:,2)) - min(boundary(:,2)), ...
                                   max(boundary(:,1)) - min(boundary(:,1))];
                rectangle('Position', tearBoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
                text(tearBoundingBox(1) + tearBoundingBox(3)/2, tearBoundingBox(2) + tearBoundingBox(4)/2, 'Tear', 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            end
        end
    end
end


