function result = colorSegment()

first_img = imread('red2.png');
imgs = cell(2, 1);
imgs{1} = 'red2.png';
imgs{2} = 'red1.png';
imshow(first_img);
[x, y] = ginput(1);
x = floor(x);
y = floor(y);

hsv = rgb2hsv(first_img);
h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);
imshow(h);
hLow = 0;
hHigh = graythresh(h);
sLow = s(y, x) - .2;
sHigh = s(y, x) + .2;
vLow = v(y, x) - .2;
vHigh = v(y, x) + .2;

for i = 1:size(imgs, 1)
    hsv = rgb2hsv(imread(imgs{i}));
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    hMask = (h >= hLow) & (h <= hHigh);
    imshow(hMask);
    sMask = (s >= sLow) & (s <= sHigh);
    imshow(sMask);
    vMask = (v >= vLow) & (v <= vHigh);
    imshow(vMask);
    objMask = uint8(hMask & sMask & vMask);
    imshow(objMask);

    props = regionprops(bwlabel(objMask), 'area');
    maxArea = max([props.Area])
    minObjArea = maxArea - 1;
    objMask = uint8(bwareaopen(objMask, minObjArea));
    str_el = strel('disk', 10);
    objMask = imclose(objMask, str_el);
    imshow(objMask, []);
    hold on;
    props = regionprops(bwlabel(objMask), 'Centroid');
    centroid = props.Centroid
    plot(centroid(1), centroid(2), 'r*');
end
end
