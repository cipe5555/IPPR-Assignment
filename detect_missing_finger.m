function [finger_candidates, curvature_candidates, missing_finger] = detect_missing_finger(image, main_glove_contour, glove_convex_hull)

    [~, finger_stats] = detect_skin_contour(image);

    % Extract the vertices of the convex hull
    % convex_hull_vertices = main_glove_contour(glove_convex_hull,:);
    glove_contour_x = main_glove_contour(:, 2);
    glove_contour_y = main_glove_contour(:, 1);
    
    % Step 2: Find Centroid
    hull_centroid = [mean(glove_contour_x(glove_convex_hull)), mean(glove_contour_y(glove_convex_hull))];
    
    % Step 3: Find Finger Points
    distances = sqrt((glove_contour_x(glove_convex_hull) - hull_centroid(1)).^2 + (glove_contour_y(glove_convex_hull) - hull_centroid(2)).^2);
    % [sorted_distances, sorted_indices] = sort(distances);
    
    min_distance_threshold = mean(distances) - 0.35 * mean(distances);
    max_distance_threshold = mean(distances) + 0.35 * mean(distances);
    min_spacing_threshold = 0.25 * mean(distances);
    
    % Initialize finger candidates
    finger_candidates = [];
    curvature_candidates = [];
    
    % Iterate through points on the convex hull
    for i = 1:numel(glove_convex_hull)
        current_index = glove_convex_hull(i);
        
        % Compute distance from current point to hull centroid
        distance_to_centroid = distances(i);
    
        % Check if the point is on the boundary of the image
        if glove_contour_x(current_index) == 1 || glove_contour_x(current_index) == size(image, 2) || glove_contour_y(current_index) == 1 || glove_contour_y(current_index) == size(image, 1)
            curvature = NaN; % Boundary points don't have curvature
        else
            % Extract the x and y coordinates of the points surrounding the selected point
            x = glove_contour_x(glove_convex_hull);
            y = glove_contour_y(glove_convex_hull);
        
            % Fit a polynomial curve to the points around the selected point (adjust the polynomial order as needed)
            poly_order = 2; % Adjust as needed
            fit_range = max(1, i - 5) : min(numel(glove_convex_hull), i + 5); % Adjust the range of points to fit
            p = polyfit(x(fit_range), y(fit_range), poly_order);
        
            % Evaluate the polynomial and its derivatives at the selected point
            y_prime = polyval(p, x(i), 1); % First derivative (y')
            y_double_prime = polyval(p, x(i), 2); % Second derivative (y'')
        
            % Calculate curvature using the formula: curvature = |y''| / (1 + y'^2)^(3/2)
            curvature = abs(y_double_prime) / (1 + y_prime^2)^(3/2);
            curvature = curvature * 100000; % Scale curvature by a factor
        end
    
        % Check if the current point is a finger candidate based on distance
        if distance_to_centroid >= min_distance_threshold && distance_to_centroid <= max_distance_threshold
            % Check if the point is sufficiently spaced from other fingers
            if isempty(finger_candidates) || ...
               all(sqrt((glove_contour_x(current_index) - glove_contour_x(finger_candidates)).^2 + ...
                        (glove_contour_y(current_index) - glove_contour_y(finger_candidates)).^2) > min_spacing_threshold)
                % Check if the current point is a finger candidate based on curvature
                if curvature >= 0.1
                    % Add the point as a finger candidate
                    finger_candidates = [finger_candidates, current_index];
                    curvature_candidates = [curvature_candidates, curvature];
                end
            end
        end
    end

    num_missing_finger = max(0, 5 - numel(finger_candidates));

    disp('Number of missing finger:');
    disp(num_missing_finger);

    distances = zeros(length(finger_stats), 1);
    missing_finger = [];
    if num_missing_finger > 0
        for i = 1:length(finger_stats)
            % % Extract bounding box centroid
            bbox_center = [finger_stats(i).BoundingBox(1) + finger_stats(i).BoundingBox(3)/2, ...
                           finger_stats(i).BoundingBox(2) + finger_stats(i).BoundingBox(4)/2];
            % is_inside = inpolygon(bbox_center(2), bbox_center(1), main_glove_contour(:,1), main_glove_contour(:,2));
            % disp(i);
            % disp(finger_stats(i).Area);
            % if finger_stats(i).Area > 5000 && ~is_inside
                % Calculate distance
                % disp('true');
                distances(i) = sqrt((hull_centroid(1) - bbox_center(1))^2 + (hull_centroid(2) - bbox_center(2))^2);
            % end
        end

        disp('Number of distances:');
        disp(numel(distances));

        % Sort distances
        [~, sorted_indices] = sort(distances);

        % Select the two closest bounding boxes
        closest_indices = [];
        for i = 1:numel(sorted_indices)
            current_index = sorted_indices(i);
            % Extract bounding box centroid
            bbox_center = [finger_stats(current_index).BoundingBox(1) + finger_stats(current_index).BoundingBox(3)/2, ...
                           finger_stats(current_index).BoundingBox(2) + finger_stats(current_index).BoundingBox(4)/2];
            is_inside = inpolygon(bbox_center(2), bbox_center(1), main_glove_contour(:,1), main_glove_contour(:,2));
            if finger_stats(current_index).Area > 1200 && ~is_inside
                closest_indices = [closest_indices, sorted_indices(i)];
                if numel(closest_indices) == num_missing_finger
                    break;
                end
            end
        end
        % closest_indices = sorted_indices(1:min(num_missing_finger, numel(sorted_indices)));

        % Extract corresponding bounding boxes
        missing_finger = finger_stats(closest_indices);  
    end
end









