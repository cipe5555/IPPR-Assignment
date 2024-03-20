close all;

% Read the glove image
original_img = imread('img9.jpg');
% glove_image = find_glove_contour(original_img);

gray_img = rgb2gray(original_img);
glove_contour = detect_glove_contour(original_img);
glove_mask = poly2mask(glove_contour(:,2), glove_contour(:,1), size(gray_img, 1), size(gray_img, 2));

figure; imshow(original_img);
hold on;
plot(glove_contour(:,2), glove_contour(:,1), 'g', 'LineWidth', 2);
hold off;

% Create a new image where everything outside the contour is remove
masked_image = original_img;
for i = 1:3 % Iterate over each color channel (RGB)
    masked_image(:,:,i) = original_img(:,:,i) .* uint8(glove_mask);
end

% Convert the image to HSV color space
hsvImage = rgb2hsv(masked_image);

% Extract individual channels
hueChannel = hsvImage(:,:,1);
hue_in_contour = hueChannel(hueChannel > 0);

saturationChannel = hsvImage(:,:,2);
saturation_in_contour = saturationChannel(saturationChannel > 0);

valueChannel = hsvImage(:,:,3);
value_in_contour = valueChannel(valueChannel > 0);

% Calculate statistics of the hue channel
hueMean = mean2(hue_in_contour);
hueStd = std2(hue_in_contour);

saturationMean = mean2(saturation_in_contour);
saturationStd = std2(saturation_in_contour);

valueMean = mean2(value_in_contour);
valueStd = std2(value_in_contour);

% Define threshold ranges based on statistics
threshold_multipler = 3.0;
hueThreshold = [hueMean - threshold_multipler*hueStd, hueMean + threshold_multipler*hueStd]; % Adjust factor as needed
saturationThreshold = [saturationMean - threshold_multipler*saturationStd, saturationMean + threshold_multipler*saturationStd]; % Example threshold range for saturation
valueThreshold = [valueMean - threshold_multipler*valueStd, valueMean + threshold_multipler*valueStd]; % Example threshold range for value

% disp(hueThreshold);
% disp(saturationThreshold);
% disp(valueThreshold);

% Thresholding
binaryMask = (hueChannel >= hueThreshold(1) & hueChannel <= hueThreshold(2)) & ...
             (saturationChannel >= saturationThreshold(1) & saturationChannel <= saturationThreshold(2)) & ...
             (valueChannel >= valueThreshold(1) & valueChannel <= valueThreshold(2));

% Perform morphological operations
binaryMask = imclose(binaryMask, strel('disk', 5)); % Example closing operation

figure;
imshow(original_img);
title('Original Image');
% figure;
% imshow(glove_image);
% title('Glove Image');
figure;
imshow(hsvImage);
title('HSV Image');
impixelinfo;
figure;
imshow(binaryMask);
title('Binary Mask');







