close all;

%%% ONLY WORKS FOR COLOUR IMAGE NOW
img = imread('img1.jpg');
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

figure; imshow(img);

figure; imshow(label2rgb(glove_extracted));
hold on;
plot(largest_countour(:, 2), largest_countour(:, 1), 'g', 'LineWidth', 2);

figure; imshow(glove_extracted);

