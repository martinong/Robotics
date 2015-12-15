function [maxArea, obj_x] = colorSegment(serPort)

first_img = imread('http://192.168.0.100/img/snapshot.cgi?');
imshow(first_img);
img_width = size(first_img, 2);
[x, y] = ginput(1);
x = floor(x);
y = floor(y);

hsv = rgb2hsv(first_img);
h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);
% figure;imshow(h);
% figure;imshow(s);
% figure;imshow(v);

hLow = h(y,x) - .2;
hHigh = h(y, x) + .2;
sLow = s(y, x) - .2;
sHigh = s(y, x) + .2;
vLow = v(y, x) - .2;
vHigh = v(y, x) + .2;
% h(y,x)
% s(y,x)
% v(y,x)

initArea = 0;

while true
    img = imread('http://192.168.0.100/img/snapshot.cgi?');
    hsv = rgb2hsv(img);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    hMask = (h >= hLow) & (h <= hHigh);
%     imshow(hMask);
    sMask = (s >= sLow) & (s <= sHigh);
%     imshow(sMask);
    vMask = (v >= vLow) & (v <= vHigh);
%     imshow(vMask);
    objMask = uint8(hMask & sMask & vMask);
%     imshow(objMask);
    props = regionprops(logical(objMask), 'area');
    maxArea = max([props.Area]);
    minObjArea = maxArea - 1;
    if (size(props, 1) == 0)
        display 'no regions';
        continue;
    end
    objMask = uint8(bwareaopen(objMask, minObjArea));
    str_el = strel('disk', 25);
    objMask = imclose(objMask, str_el);
%     imshow(objMask, []);
%     hold on;
    props = regionprops(logical(objMask), 'Centroid');
    centroid = props.Centroid;
    obj_x = centroid(1);
%     plot(centroid(1), centroid(2), 'r*');
%     pause(.1);
    if (initArea ~= 0)
        center_dist = obj_x - img_width/2;
        diffArea = (initArea - maxArea)/initArea;
        moveRobot(serPort, center_dist, diffArea);
    else
        initArea = maxArea
    end
    
end
end

function moveRobot(serPort, center_dist, diffArea)
diffArea
center_dist;
angle = -center_dist/4;
% Rough
if (abs(center_dist) > 50)
    turnAngle(serPort, 0.1, angle/4);
    pause(0.1);
elseif(abs(diffArea) > .5)
   SetFwdVelRadiusRoomba(serPort, diffArea, Inf); 
   pause(0.1);
%    SetFwdVelRadiusRoomba(serPort, 0, 2);
end
% Precise
if (abs(center_dist) > 10)
    turnAngle(serPort, 0.1, angle);
    pause(0.1);
elseif(abs(diffArea) > .15)
   SetFwdVelRadiusRoomba(serPort, diffArea/2, Inf); 
   pause(0.1);
%    SetFwdVelRadiusRoomba(serPort, 0, 2);
end

end
