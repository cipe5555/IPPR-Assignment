function stain_or_dirt = detect_stain(image, boundary, k)
    
    % image = imread('img24.jpg');
    % figure; imshow(image);
    glove_hsv = rgb2hsv(image);

    % Extract the region inside the contour
    % mask = poly2mask(boundary(:,2), boundary(:,1), size(glove_hsv, 1), size(glove_hsv, 2));
    % stain_roi = glove_hsv .* repmat(mask, [1 1 3]);

    % if k == 34
    %     figure; imshow(image); title('detect stain boundary 34');
    %     hold on;
    %     plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
    %     hold off;
    % end
    % figure; imshow(mask); title('mask');

    hue_channel = glove_hsv(boundary(:,1),boundary(:,2),1);
    saturation_channel = glove_hsv(boundary(:,1),boundary(:,2),2);
    value_channel = glove_hsv(boundary(:,1),boundary(:,2),3);

    % Calculate histograms for each channel
    numBins = 256;
    hueHistogram = imhist(hue_channel, numBins);
    saturationHistogram = imhist(saturation_channel, numBins);
    valueHistogram = imhist(value_channel, numBins);

    % Find the bin with the highest count for each channel
    [~, dominantHueBin] = max(hueHistogram);
    [~, dominantSaturationBin] = max(saturationHistogram);
    [~, dominantValueBin] = max(valueHistogram);

    % Convert the dominant bins to actual values
    dominant_hue = (dominantHueBin - 1) / numBins;
    dominant_saturation = (dominantSaturationBin - 1) / numBins;
    dominant_value = (dominantValueBin - 1) / numBins;

    % Extract the dominant color
    dominant_color = [dominant_hue, dominant_saturation, dominant_value];

    % if k == 14
    %     disp(dominant_color);
    % end

    % stain_threshold_radius = 5;
    dark_stain_lower = [0,0,0] / 255;
    dark_stain_upper = [255,255,127] / 255;

    dirt_lower = [20,20,50] / 255;
    dirt_upper = [90,150,255] / 255;

    % count_in_range = 0;
    % count_threshold = stain_threshold_radius^2*0.75;
    min_stain_area = 2000;
    min_dirt_area = 2000;

    % Check if dominant color is within the first range
    is_dirt_colour = all(dominant_color >= dirt_lower) && all(dominant_color <= dirt_upper);
    is_dirt = is_dirt_colour && polyarea(boundary(:,2), boundary(:,1)) > min_dirt_area;

    if is_dirt
        stain_or_dirt = 'Dirt';
    else
        is_stain_colour = all(dominant_color >= dark_stain_lower) && all(dominant_color <= dark_stain_upper);
        is_stain = is_stain_colour && polyarea(boundary(:,2), boundary(:,1)) > min_stain_area;
        if is_stain
            stain_or_dirt = 'Stain';
        else
            stain_or_dirt = 'None';
        end
    end
end