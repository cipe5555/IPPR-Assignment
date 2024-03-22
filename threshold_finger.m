function [thresholded_finger, main_finger_contour] = threshold_finger(image)
    % Read the glove image
    % original_img = imread('imgg4.jpg');
    % finger_image = find_finger_contour(original_img);
    
    gray_img = rgb2gray(image);
    main_glove_contour = detect_glove_contour(image); % This function needs to be defined to find the glove contour
    glove_mask = poly2mask(main_glove_contour(:,2), main_glove_contour(:,1), size(gray_img, 1), size(gray_img, 2));
    
    % Invert glove_mask to find areas not covered by the glove
    inverted_glove_mask = ~glove_mask;
    
    % Find contours in the inverted mask, which should reveal the uncovered finger
    [B,~] = bwboundaries(inverted_glove_mask, 'noholes');
    
    % Find the largest boundary which should be the uncovered finger
    max_boundary = max(cellfun(@length, B));
    main_finger_contour = B{cellfun(@length, B) == max_boundary};
    
    % Draw the contour of the uncovered finger
    figure; imshow(image);
    hold on;
    plot(main_finger_contour(:,2), main_finger_contour(:,1), 'b', 'LineWidth', 2);
    hold off;
    
    % Create a new image where everything outside the finger contour is remove
    masked_finger_image = uint8(inverted_glove_mask) .* gray_img;
    
    % Thresholding - to separate the finger from the background
    finger_threshold = graythresh(masked_finger_image); % Using Otsu's method to find the threshold
    thresholded_finger = imbinarize(masked_finger_image, finger_threshold);
    
    % Perform morphological operations to clean up the image
    thresholded_finger = imclose(thresholded_finger, strel('disk', 5)); % Example closing operation
    
    % Show the thresholded finger
    % figure;
    % imshow(thresholded_finger);
    % title('Uncovered Finger');
end