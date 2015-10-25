function rect(map)
diameter = .4;
keyset = keys(map);
points = zeros(length(keyset), 2);
for i=1:length(keyset)
   points(i, :) = toXY(keyset{i}); 
end
% minX = min(points(:, 1));
% minY = min(points(:, 2));
% maxX = max(points(:, 1));
% maxX = max(points(:, 2));
% width = maxX - minX;
% height = maxY - minY;
figure();
for i=1:length(points)
    x = points(i, 1);
    y = points(i, 2);
    toChar(x,y)
    if (~isKey(map, toChar(x,y)))
        rectangle('position',[x * diameter y * diameter diameter diameter],'facecolor','black');
    elseif (map(toChar(x, y)) == 1)
        rectangle('position',[x * diameter y * diameter diameter diameter],'facecolor','y');
    elseif (map(toChar(x, y)) == 2)
        rectangle('position',[x * diameter y * diameter diameter diameter],'facecolor','r');
    end
end
end

function str = toChar(x, y)
str = strcat(num2str(x), ' ', num2str(y));
end

function xy =  toXY(str)
p = strsplit(str);
x = str2num(p{1});
y = str2num(p{2});
xy = [x y];
end