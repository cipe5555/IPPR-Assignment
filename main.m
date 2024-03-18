% % Read the glove image
% glove_image = imread('img5.jpg');
% 
% % glove_bounding_box = find_glove_contour(glove_image);
% % figure;
% % imshow(glove_bounding_box);
% % 
% % figure; imshow(glove_image);
% 
% % Call the detect_tear function
% [is_tear_detected, tear_bbox] = detect_tear(glove_image);
% 
% % Display the result
% if is_tear_detected
%     % Draw the bounding box on the image
%     figure;
%     imshow(glove_image);
%     hold on;
%     rectangle('Position', tear_bbox, 'EdgeColor', 'r', 'LineWidth', 2);
%     hold off;
%     title('Glove image with detected tear outlined');
% else
%     disp('No tear detected in the glove image.');
% end
