close all;
clearvars;

img = imread('img9.jpg');

main_glove_contour = detect_glove_contour(img);

% Convert the image to HSV color space
img_hsv = rgb2hsv(img);
figure; imshow(img_hsv);
impixelinfo;

glove_max_threshhold = 130;
glove_min_threshhold = 70;

% glove_mask = poly2mask(main_glove_contour(:,2), main_glove_contour(:,1), size(img, 1), size(img, 2));
glove_threshold = 130;
glove_mask = img(:,:,1) < glove_threshold;
% glove_mask = (img(:,:,1) > glove_min_threshhold) & (img(:,:,1) < glove_max_threshhold);
figure; imshow(glove_mask); title('Glove Mask');
% img_fill = imfill(glove_mask, 'holes');

% img_open = bwareaopen(img_fill, 100);
% figure; imshow(img_open);

se = strel('disk', 5);
img_close = imclose(glove_mask, se);

boundaries = bwboundaries(img_close);

min_area_threshold = 1000;

figure;
imshow(img);
hold on;
plot(main_glove_contour(:,2), main_glove_contour(:,1), 'r', 'LineWidth', 2);
for k = 1:length(boundaries)
    boundary = boundaries{k};

    % plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
    if size(main_glove_contour, 1) - size(boundary, 1) > 5000

        % Calculate centroid of the current contour
        % centroid = mean(boundary);
        bounding_box = [min(boundary(:,2)), min(boundary(:,1)), ...
                                   max(boundary(:,2)) - min(boundary(:,2)), ...
                                   max(boundary(:,1)) - min(boundary(:,1))];
        centroid = [bounding_box(1) + bounding_box(3)/2, bounding_box(2) + bounding_box(4)/2];
        % text(centroid(1), centroid(2), num2str(k), 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

        % Check if centroid is inside the main glove contour
        is_inside = inpolygon(centroid(2), centroid(1), main_glove_contour(:,1), main_glove_contour(:,2));
        
        if is_inside
        % if k == 66
            % plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
            % disp(is_inside);
            % rectangle('Position', bounding_box, 'EdgeColor', 'r', 'LineWidth', 2);
            % text(centroid(1), centroid(2), 'Tear', 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            tearArea = polyarea(boundary(:,2), boundary(:,1));
            distances = sqrt(sum(bsxfun(@minus, boundary, centroid).^2, 2));

            if tearArea > min_area_threshold 

                rectangle('Position', bounding_box, 'EdgeColor', 'b', 'LineWidth', 2);
                text(centroid(1), centroid(2), 'Tear', 'Color', 'b', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            end
        end
    end
end


