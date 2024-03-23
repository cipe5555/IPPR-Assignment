close all;
clearvars;

img = imread('img1.jpg');
[rows, cols, ~] = size(img);

glove_type = 'Nitrile';

% Resize the image
target_size = 1500;
scale_width = cols/target_size;
scale_height = rows/target_size;
if scale_height > scale_width
    target_size = [target_size NaN];
else
    target_size = [NaN target_size];
end
img = imresize(img, target_size);

% Extract the main glove contour
[glove_mask, main_glove_contour, glove_convex_hull] = threshold_glove(img);

% Extract the contours in the glove
boundaries = bwboundaries(glove_mask);

% Extract the vertices of the convex hull
convex_hull_vertices = main_glove_contour(glove_convex_hull,:);
glove_contour_x = main_glove_contour(:, 2);
glove_contour_y = main_glove_contour(:, 1);

% Detect missing fingers
[finger_candidates, curvature_candidates, missing_finger] = detect_missing_finger(img, main_glove_contour, glove_convex_hull);
num_fingers = numel(finger_candidates);

% Detect openings
openings = detect_opening(main_glove_contour, img);

% Define hole and tear threshold
min_tear_area = 1200;
min_hole_area = 520;
max_hole_area = 1200;

% Display result
figure;
imshow(img);
hold on;

% Plot the convex hull
plot(main_glove_contour(glove_convex_hull,2), main_glove_contour(glove_convex_hull,1), 'b', 'LineWidth', 2);

for k = 1:length(boundaries)
    
    boundary = boundaries{k};

    % Exclude the main glove contour itself
    if size(main_glove_contour, 1) - size(boundary, 1) > size(main_glove_contour, 1) - (size(main_glove_contour, 1)*0.9)

        bounding_box = [min(boundary(:,2)), min(boundary(:,1)), ...
                                   max(boundary(:,2)) - min(boundary(:,2)), ...
                                   max(boundary(:,1)) - min(boundary(:,1))];
        box_centroid = [bounding_box(1) + bounding_box(3)/2, bounding_box(2) + bounding_box(4)/2];
        defect_area = polyarea(boundary(:,2), boundary(:,1));

        % Check if centroid is inside the main glove contour
        is_inside = inpolygon(box_centroid(2), box_centroid(1), main_glove_contour(:,1), main_glove_contour(:,2));

        if is_inside

            % Detect stain and dirt
            stain_or_dirt = detect_stain_and_dirt(img, boundary);

            text_position = [bounding_box(1) + 7, bounding_box(2) - 23];
            if strcmp(stain_or_dirt, 'Dirt')
                rectangle('Position', bounding_box, 'EdgeColor', 'r', 'LineWidth', 1);
                text(text_position(1), text_position(2), 'Dirt', 'Color', 'black', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'BackgroundColor', 'r', 'FontSize', 7);
            elseif strcmp(stain_or_dirt, 'Stain')
                rectangle('Position', bounding_box, 'EdgeColor', 'r', 'LineWidth', 1);
                text(text_position(1), text_position(2), 'Stain', 'Color', 'black', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'BackgroundColor', 'r', 'FontSize', 7);
            elseif defect_area < max_hole_area && defect_area > min_hole_area
                rectangle('Position', bounding_box, 'EdgeColor', 'r', 'LineWidth', 1);
                text(text_position(1), text_position(2), 'Hole', 'Color', 'black', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'BackgroundColor', 'r', 'FontSize',7);
            elseif defect_area >= min_tear_area 
                rectangle('Position', bounding_box, 'EdgeColor', 'r', 'LineWidth', 1);
                text(text_position(1), text_position(2), 'Tear', 'Color', 'black', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'BackgroundColor', 'r', 'FontSize', 7);
            end

            if ~isempty(openings) && strcmp(glove_type, 'Nitrile')
                for i = 1:length(openings)
                    rectangle('Position', openings{i},'EdgeColor','r','LineWidth',1);
                    text_position = [openings{i}(1) + 7, openings{i}(2) - 23];
                    text(text_position(1), text_position(2), 'Opening', 'Color', 'black', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'BackgroundColor', 'r', 'FontSize', 7);
                end
            end

            if ~isempty(missing_finger) && ~strcmp(glove_type, 'Nitrile')
                 for i = 1:length(missing_finger)
                    rectangle('Position', missing_finger(i).BoundingBox,'EdgeColor','r','LineWidth',1);
                    text_position = [missing_finger(i).BoundingBox(1) + 7, missing_finger(i).BoundingBox(2) - 23];
                    text(text_position(1), text_position(2), 'Missing Finger', 'Color', 'black', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'BackgroundColor', 'r', 'FontSize', 7);
                 end      
            end
        end
    end
end
hold off


