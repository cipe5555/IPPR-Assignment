function [finger_mask, finger_bbox] = extract_only_finger_mask(image)
% Convert image to the HSV color space
    hsv_image = rgb2hsv(image);

    % Define skin color range in HSV
    % These thresholds may need adjustment for different skin tones and lighting conditions
    hueRange = [0.01, 0.1]; % Hue range for skin tones
    saturationRange = [0.3, 0.7]; % Saturation range for skin tones
    valueRange = [0.35, 1]; % Value range for brightness
    
    % Create a binary mask based on the defined thresholds
    skin_mask = (hsv_image(:,:,1) >= hueRange(1)) & (hsv_image(:,:,1) <= hueRange(2)) & ...
                (hsv_image(:,:,2) >= saturationRange(1)) & (hsv_image(:,:,2) <= saturationRange(2)) & ...
                (hsv_image(:,:,3) >= valueRange(1)) & (hsv_image(:,:,3) <= valueRange(2));

    % Perform morphological operations to clean up the mask
    se = strel('disk', 5);
    skin_mask_clean = imclose(skin_mask, se);
    skin_mask_clean = imfill(skin_mask_clean, 'holes');

    % Subtract the glove mask from the skin mask
    [glove_mask, ~] = threshold_glove(image); % Assuming threshold_glove function returns the glove mask
    skin_mask_no_glove = skin_mask_clean & ~glove_mask;

    % Label connected components
    [labeledImage, numObjects] = bwlabel(skin_mask_no_glove);
    stats = regionprops(labeledImage, 'Area', 'BoundingBox', 'PixelIdxList');

    % Find the largest object that is presumably the finger
    maxArea = 0;
    fingerIdx = 0;
    finger_bbox = [];
    for k = 1:numObjects
        if stats(k).Area > maxArea
            maxArea = stats(k).Area;
            fingerIdx = k;
            finger_bbox = stats(k).BoundingBox;
        end
    end
    
    % Create a mask for only the finger
    finger_mask = false(size(image, 1), size(image, 2));
    if fingerIdx > 0
        finger_mask(stats(fingerIdx).PixelIdxList) = true;
    end

    figure; imshow(image);
    hold on;
    % rectangle('Position', finger_bbox, 'EdgeColor', 'r', 'LineWidth', 2);
    hold off;
    % title('Extracted Finger Mask with Bounding Box');
end


