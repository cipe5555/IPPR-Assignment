close all;

%%% ONLY WORKS FOR COLOUR IMAGE NOW
img = imread('img6.jpg');
img_hsv = rgb2hsv(img);

glove_lower = [0,0,0] / 255; % Normalize to the range [0, 1]
glove_upper = [255,120,255] / 255; % Normalize to the range [0, 1]

glove_mask = (img_hsv(:,:,1) >= glove_lower(1) & img_hsv(:,:,1) <= glove_upper(1)) & ...
       (img_hsv(:,:,2) >= glove_lower(2) & img_hsv(:,:,2) <= glove_upper(2)) & ...
       (img_hsv(:,:,3) >= glove_lower(3) & img_hsv(:,:,3) <= glove_upper(3));

glove_extracted = img_hsv;

glove_extracted(repmat(~glove_mask,[1 1 3])) = 0; % Set pixels outside the mask to zero

glove_extracted = glove_extracted(:,:,1) > 0 | glove_extracted(:,:,2) > 0 | glove_extracted(:,:,3) > 0;

glove_extracted = imcomplement(glove_extracted);

se = strel('square', 3);
glove_extracted = imerode(glove_extracted, se);
glove_extracted = imdilate(glove_extracted, se);

[glove_countours, ~] = bwboundaries(glove_extracted, 'noholes');

largest_countour = [];
largest_countour_area = -1;

for i = 1:length(glove_countours)
    current_countour = glove_countours{i};
    current_countour_area = polyarea(current_countour(:, 2), current_countour(:, 1));

    if current_countour_area > largest_countour_area
        largest_countour = current_countour;
        largest_countour_area = current_countour_area;
    end
end

%hold on;
%plot(largest_countour(:, 2), largest_countour(:, 1), 'g', 'LineWidth', 2);

%figure; imshow(glove_extracted);

img_fill = imfill(glove_extracted, 'holes'); % Fill holes
img_sub = img_fill & -glove_extracted

% Label the defects
labeled_defects = bwlabel(img_sub);
%figure; imshow(labeled_defects);

%figure; imshow(label2rgb(glove_extracted));

 % Measure properties of image regions
    stats = regionprops(labeled_defects, 'Area', 'Centroid');
    
    % Show the original image
    imshow(img);
    hold on;
    
    % Loop through each defect and annotate them
    for i = 1:numel(stats)
        defect_area = stats(i).Area;
        centroid = stats(i).Centroid;
        if stats(i).Area < 100000
            text(centroid(1), centroid(2), sprintf('Defect %d: Area = %d', i, defect_area), 'Color', 'r');
        end
    end
    hold off
