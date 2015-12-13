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
imshow(h);
hLow = h(y,x) - .3;
hHigh = h(y, x) + .3;
sLow = s(y, x) - .2;
sHigh = s(y, x) + .2;
vLow = v(y, x) - .2;
vHigh = v(y, x) + .2;

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
    props = regionprops(bwlabel(objMask), 'area');
    maxArea = max([props.Area]);
    minObjArea = maxArea - 1;
    objMask = uint8(bwareaopen(objMask, minObjArea));
    str_el = strel('disk', 25);
    objMask = imclose(objMask, str_el);
    imshow(objMask, []);
    hold on;
    props = regionprops(bwlabel(objMask), 'Centroid');
    centroid = props.Centroid;
    obj_x = centroid(1);
    plot(centroid(1), centroid(2), 'r*');
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
diffArea;
if (abs(center_dist) > 5)
    turnAngle(serPort, 0.1, -center_dist/10);
elseif(abs(diffArea) > .1)
   SetFwdVelRadiusRoomba(serPort, diffArea/10 + .15, 2); 
end
% pause(.1);

end

function knockDoor(setPort)

hLow = .64;
hHigh = 1;
sLow =.5;
sHigh = .9;
vLow = .26;
vHigh = .66;

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
    props = regionprops(bwlabel(objMask), 'area');
    maxArea = max([props.Area]);
    minObjArea = maxArea - 1;
    if(maxArea < 1000)
       turnAngle(serPort, 0.1, 20);
       continue;
    end
    objMask = uint8(bwareaopen(objMask, minObjArea));
    str_el = strel('disk', 25);
    objMask = imclose(objMask, str_el);
    imshow(objMask, []);
    hold on;
    props = regionprops(bwlabel(objMask), 'Centroid');
    centroid = props.Centroid;
    obj_x = centroid(1);
    plot(centroid(1), centroid(2), 'r*');
%     pause(.1);
    center_dist = obj_x - img_width/2;
    if (abs(center_dist) > 5)
        turnAngle(serPort, 0.1, -center_dist/10);
    else
        break;
    end

end

% Go forward until bump
[ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
bumped = BumpRight || BumpLeft || BumpFront;
while (~bumped)
    [ BumpRight, BumpLeft, ~, ~, ~, BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    bumped = BumpRight || BumpLeft || BumpFront;
    if(bumped)
        SetFwdVelRadiusRoomba(serPort, -0.2, inf);
        pause(.1);
        SetFwdVelRadiusRoomba(serPort, 0.2, inf);
        pause(.1);
        SetFwdVelRadiusRoomba(serPort, -0.2, inf);
        pause(.1);
        SetFwdVelRadiusRoomba(serPort, 0, inf);
        BeepRoomba(serPort);
        BeepRoomba(serPort);
        BeepRoomba(serPort);
        SetFwdVelRadiusRoomba(serPort, .2, inf);
        pause(.2);
    end
    SetFwdVelRadiusRoomba(serPort, 0.2, inf);
    pause(0.05);
end
SetFwdVelRadiusRoomba(serPort, 0, 2);
end
    
