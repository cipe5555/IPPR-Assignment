close all;
clearvars;

img = imread('img32.jpg');
figure; imshow(img); title('original');
[rows, cols, ~] = size(img);
disp(size(img));

target_size = 1500;
scale_width = cols/target_size;
scale_height = rows/target_size;

if scale_height > scale_width
    target_size = [target_size NaN];
else
    target_size = [NaN target_size];
end

img = imresize(img, target_size);
% figure; imshow(resized_img); title('resized');

disp(size(img));

% main_glove_contour = detect_glove_contour(img);
[glove_mask, main_glove_contour] = threshold_glove(img);

figure; imshow(glove_mask); title('Glove Mask');
% img_fill = imfill(glove_mask, 'holes');

% img_open = bwareaopen(img_fill, 100);
% figure; imshow(img_open);

% se = strel('disk', 5);
% img_close = imclose(glove_mask, se);

boundaries = bwboundaries(glove_mask);

min_tear_area = 1200;

min_hole_area = 520;
max_hole_area = 1200;

% stain_threshold_radius = 5;
% stain_lower = [0,0,0] / 255;
% stain_upper = [255,255,126] / 255;
% count_in_range = 0;
% count_threshold = stain_threshold_radius^2*0.75;
% min_stain_area = 2000;

figure;
imshow(img);
hold on;
plot(main_glove_contour(:,2), main_glove_contour(:,1), 'r', 'LineWidth', 2);
for k = 1:length(boundaries)
    boundary = boundaries{k};

    % plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
    % disp(size(main_glove_contour, 1));
    % disp(size(boundary, 1));
    if size(main_glove_contour, 1) - size(boundary, 1) > size(main_glove_contour, 1) - (size(main_glove_contour, 1)*0.9)

        % plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
        % Calculate centroid of the current contour
        % centroid = mean(boundary);
        bounding_box = [min(boundary(:,2)), min(boundary(:,1)), ...
                                   max(boundary(:,2)) - min(boundary(:,2)), ...
                                   max(boundary(:,1)) - min(boundary(:,1))];
        centroid = [bounding_box(1) + bounding_box(3)/2, bounding_box(2) + bounding_box(4)/2];
        defect_area = polyarea(boundary(:,2), boundary(:,1));

        % text(centroid(1), centroid(2), num2str(defect_area), 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

        % text(centroid(1), centroid(2), num2str(k), 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

        % Check if centroid is inside the main glove contour
        is_inside = inpolygon(centroid(2), centroid(1), main_glove_contour(:,1), main_glove_contour(:,2));

        if is_inside

            % disp(k);
            stain_or_dirt = detect_stain(img, boundary, k);
            % distances = sqrt(sum(bsxfun(@minus, boundary, centroid).^2, 2));

            if strcmp(stain_or_dirt, 'Dirt')
                rectangle('Position', bounding_box, 'EdgeColor', 'b', 'LineWidth', 2);
                text(centroid(1), centroid(2), 'Dirt', 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            elseif strcmp(stain_or_dirt, 'Stain')
                rectangle('Position', bounding_box, 'EdgeColor', 'b', 'LineWidth', 2);
                text(centroid(1), centroid(2), 'Stain', 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            elseif defect_area < max_hole_area && defect_area > min_hole_area
                rectangle('Position', bounding_box, 'EdgeColor', 'b', 'LineWidth', 2);
                text(centroid(1), centroid(2), 'Hole', 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            elseif defect_area >= min_tear_area 
                rectangle('Position', bounding_box, 'EdgeColor', 'b', 'LineWidth', 2);
                text(centroid(1), centroid(2), 'Tear', 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            end
        end
    end
end
hold off


