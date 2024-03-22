close all;
clearvars;

img = imread('imgg4.jpg');
[rows, cols, ~] = size(img);

% main_glove_contour = detect_glove_contour(img);
[glove_mask, main_glove_contour] = threshold_glove(img);
%[finger_mask, main_finger_contour] = threshold_finger(img);
[finger_only_mask, finger_bbox] = extract_only_finger_mask(img);

%figure; imshow(glove_mask); title('Glove Mask');

%finger only mask
% finger_mask = finger_mask & ~glove_mask;
% %figure; imshow(finger_mask); title('im finger');
% 
%  % Find contours on the finger_only_mask to get the main finger contour
%     finger_mask = bwareaopen(finger_mask, 50); % Remove small objects
%     finger_mask = imfill(finger_mask, 'holes'); % Fill holes in the binary image
% 
%     % Assuming the largest contour is the finger after glove subtraction
%     % max_boundary_length = 0;
%     % for k = 1:length(finger_boundaries)
%     %     boundary_length = length(finger_boundaries{k});
%     %     if boundary_length > max_boundary_length
%     %         max_boundary_length = boundary_length;
%     %         main_finger_contour = finger_boundaries{k};
%     %     end
%     % end
% 
%     figure; imshow(finger_mask);title('im finger');



% img_fill = imfill(glove_mask, 'holes');

% img_open = bwareaopen(img_fill, 100);
% figure; imshow(img_open);

% se = strel('disk', 5);
% img_close = imclose(glove_mask, se);

boundaries = bwboundaries(glove_mask);

min_tear_area = 5000;

min_hole_area = 600;
max_hole_area = 1000;

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
%plot(main_finger_contour(:,2), main_finger_contour(:,1), 'b', 'LineWidth', 2);
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
        

        % for i = round(max(1, centroid(2) - stain_threshold_radius)):round(min(rows, centroid(2) + stain_threshold_radius))
        %     for j = round(max(1, centroid(1) - stain_threshold_radius)):round(min(cols, centroid(1) + stain_threshold_radius))
        %         % Get the HSV value of the current pixel
        %         % centroid_hsv = img_hsv(i, j, :);
        %         centroid_hsv = reshape(img_hsv(i, j, :), 1, []); % Reshape centroid_hsv to a row vector
        %         disp(centroid_hsv);
        % 
        %         % Check if the pixel falls within the specified range
        %         if all(centroid_hsv >= stain_lower) && all(centroid_hsv <= stain_upper)
        %         % if all(centroid_hsv >= stain_lower) && all(centroid_hsv <= stain_upper)
        %             count_in_range = count_in_range + 1;        
        %         end
        %     end
        % end

        % text(centroid(1), centroid(2), num2str(defect_area), 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        
        % text(centroid(1), centroid(2), num2str(k), 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

        % Check if centroid is inside the main glove contour
        is_inside = inpolygon(centroid(2), centroid(1), main_glove_contour(:,1), main_glove_contour(:,2));

        if ~isempty(finger_bbox)
                rectangle('Position',finger_bbox,'EdgeColor','r','LineWidth',2);
                % Get the position for the text label
                textPosition = [finger_bbox(1) + finger_bbox(3)/2, finger_bbox(2) + finger_bbox(4)/2];
                text(textPosition(1), textPosition(2), 'Missing Finger', 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 8);
        end

        if is_inside

            % disp(k);
            is_stain = detect_stain(img, boundary, k);
            % distances = sqrt(sum(bsxfun(@minus, boundary, centroid).^2, 2));
            
            if is_stain
                rectangle('Position', bounding_box, 'EdgeColor', 'b', 'LineWidth', 2);
                text(centroid(1), centroid(2), 'Stain', 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            elseif defect_area < max_hole_area && defect_area > min_hole_area
                rectangle('Position', bounding_box, 'EdgeColor', 'b', 'LineWidth', 2);
                text(centroid(1), centroid(2), 'Hole', 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            elseif defect_area > min_tear_area 
                rectangle('Position', bounding_box, 'EdgeColor', 'b', 'LineWidth', 2);
                text(centroid(1), centroid(2), num2str(k), 'Color', 'r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
           
            end
        end
    end
end
hold off