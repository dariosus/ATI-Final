%test4.jpg and %test8.jpg are great examples

% Step 1: We load the image
% Note: Slightly rotated text is ok. More than slightly isn't

colorImage = imread('/home/dario/Downloads/lab_2.jpg');
figure; imshow(colorImage); title('Original image')

% The MSER algorithm has been used in text detection by Chen by combining 
% MSER with Canny edges. Canny edges are used to help cope with the 
% weakness of MSER to blur. MSER is first applied to the image in question 
% to determine the character regions. To enhance the MSER regions any 
% pixels outside the boundaries formed by Canny edges are removed. 
% The separation of the letter provided by the edges greatly increase the 
% usability of MSER in the extraction of blurred text. 

% Step 2: From the grayscale picture we detect the MSER regions

% In computer vision, maximally stable extremal regions (MSER) are 
% used as a method of blob detection in images.

grayImage = rgb2gray(colorImage);
mserRegions = detectMSERFeatures(grayImage,'RegionAreaRange',[150 2000]);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));  % extract regions

% Visualize the MSER regions overlaid on the original image
figure; imshow(colorImage); hold on;
plot(mserRegions, 'showPixelList', true,'showEllipses',false);
title('MSER regions');

% Step 3: Convert MSER pixel lists to a binary mask
mserMask = false(size(grayImage));
ind = sub2ind(size(mserMask), mserRegionsPixels(:,2), mserRegionsPixels(:,1));
mserMask(ind) = true;

% Since written text is typically placed on clear background, it tends 
% to produce high response to edge detection. Furthermore, an intersection 
% of MSER regions with the edges is going to produce regions that are even 
% more likely to belong to text.

% Step 4: Run the edge detector
edgeMask = edge(grayImage, 'Canny');

% Step 5: Find intersection between edges and MSER regions
edgeAndMSERIntersection = edgeMask & mserMask;
figure; imshowpair(edgeMask, edgeAndMSERIntersection, 'montage');
title('Canny edges and intersection of canny edges with MSER regions')

% Step 6: Grow the edges outward by using image gradients around edge locations. 
% helperGrowEdges helper function.

[~, gDir] = imgradient(grayImage);
% You must specify if the text is light on dark background or vice versa
gradientGrownEdgesMask = helperGrowEdges(edgeAndMSERIntersection, gDir, 'LightTextOnDark');
figure; imshow(gradientGrownEdgesMask); title('Edges grown along gradient direction')

% This mask can now be used to remove pixels that are within the MSER 
% regions but are likely not part of text.

% Step 7: Remove gradient grown edge pixels
edgeEnhancedMSERMask = ~gradientGrownEdgesMask & mserMask;

% Visualize the effect of segmentation
figure; imshowpair(mserMask, edgeEnhancedMSERMask, 'montage');
title('Original MSER regions and segmented MSER regions')

connComp = bwconncomp(edgeEnhancedMSERMask); % Find connected components
stats = regionprops(connComp,'Area','Eccentricity','Solidity');

% Step 8: Eliminate regions that do not follow common text measurements

% We found that the filtering in step 8 tends to discard success cases.
% In the following step it can be seen this is not used.

regionFilteredTextMask = edgeEnhancedMSERMask;

regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Eccentricity] > .995})) = 0;
regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] < 150 | [stats.Area] > 2000})) = 0;
regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Solidity] < .4})) = 0;

% Visualize results of filtering
figure; imshowpair(edgeEnhancedMSERMask, regionFilteredTextMask, 'montage');
title('Text candidates before and after region filtering')

% Step 9: Filter Character Candidates Using the Stroke Width Image

% Another useful discriminator for text in images is the variation in 
% stroke width within each text candidate. Characters in most languages 
% have a similar stroke width or thickness throughout. 
% It is therefore useful to remove regions where the stroke width exhibits 
% too much variation . The stroke width image below is computed using the 
% helperStrokeWidth helper function.

%distanceImage    = bwdist(~regionFilteredTextMask);  % Compute distance transform
distanceImage    = bwdist(~edgeEnhancedMSERMask);  % Compute distance transform
strokeWidthImage = helperStrokeWidth(distanceImage); % Compute stroke width image

% Show stroke width image
figure; imshow(strokeWidthImage);
caxis([0 max(max(strokeWidthImage))]); axis image, colormap('jet'), colorbar;
title('Visualization of text candidates stroke width')

% Step 10: Find remaining connected components

% Note that most non-text regions show a large variation in stroke width. 
% These can now be filtered using the coefficient of stroke width variation.

%connComp = bwconncomp(regionFilteredTextMask);
%afterStrokeWidthTextMask = regionFilteredTextMask;

connComp = bwconncomp(edgeEnhancedMSERMask);
afterStrokeWidthTextMask = edgeEnhancedMSERMask;
for i = 1:connComp.NumObjects
    strokewidths = strokeWidthImage(connComp.PixelIdxList{i});
    % Compute normalized stroke width variation and compare to common value
    if std(strokewidths)/mean(strokewidths) > 0.35
        afterStrokeWidthTextMask(connComp.PixelIdxList{i}) = 0; % Remove from text candidates
    end
end

% Visualize the effect of stroke width filtering
figure; imshowpair(edgeEnhancedMSERMask, afterStrokeWidthTextMask,'montage');
title('Text candidates before and after stroke width filtering')

% Step 11: Determine Bounding Boxes Enclosing Text Regions

% To compute a bounding box of the text region, we will first merge the 
% individual characters into a single connected component. 
% This can be accomplished using morphological closing followed by opening 
% to clean up any outliers.

se1=strel('disk',25);
se2=strel('disk',7);

afterMorphologyMask = imclose(afterStrokeWidthTextMask,se1);
afterMorphologyMask = imopen(afterMorphologyMask,se2);

% Display image region corresponding to afterMorphologyMask
displayImage = colorImage;
displayImage(~repmat(afterMorphologyMask,1,1,3)) = 0;
figure; imshow(displayImage); title('Image region under mask created by joining individual characters')

% Step 12: Find bounding boxes of large regions.

areaThreshold = 5000; % threshold in pixels
connComp = bwconncomp(afterMorphologyMask);
stats = regionprops(connComp,'BoundingBox','Area');
boxes = round(vertcat(stats(vertcat(stats.Area) > areaThreshold).BoundingBox));
for i=1:size(boxes,1)
    figure;
    imshow(imcrop(colorImage, boxes(i,:))); % Display segmented text
    title('Text region')
end

% Step 13:  Perform Optical Character Recognition on Text Region

% The segmentation of text from a cluttered scene can greatly improve OCR 
% results. Since our algorithm already produced a well segmented text 
% region, we can use the binary text mask to improve the accuracy of the 
% recognition results.

ocrtxt = ocr(afterStrokeWidthTextMask, boxes); % use the binary image instead of the color image
ocrtxt.Text