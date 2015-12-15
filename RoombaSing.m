function RoombaSing(serPort)
r = 30;
c4 = 60;
cis4 = 61;
des4 = 61;
d4 = 62;
dis4 = 63;
ees4 = 63;
e4 = 64;
f4 = 65;
fis4 = 66;
ges4 = 66;
g4 = 67;
gis4 = 68;
aes4 = 68;
a4 = 69;
ais4 = 70;
bes4 = 70;
b4 = 71;
c5 = 72;
cis5 = 73;
des5 = 73;
d5 = 74;
dis5 = 75;
ees5 = 75;
e5 = 76;
f5 = 77;
fis5 = 78;
ges5 = 78;
g5 = 79;
gis5 = 80;
aes5 = 80;
a5 = 81;
ais5 = 82;
bes5 = 82;
b5 = 83;
c6 = 84;
cis6 = 85;
des6 = 85;
d6 = 86;
dis6 = 87;
ees6 = 87;
e6 = 88;
f6 = 89;
fis6 = 90;
ges6 = 90;

MEASURE = 160;
HALF = MEASURE/2;
Q = MEASURE/4;
E = MEASURE/8;
Ed = MEASURE*3/16;
S = MEASURE/16;

MEASURE_TIME = MEASURE/64.;

fwrite(serPort, [140, 0, 9, a4,Q, a4,Q, a4,Q, f4,Ed, c5,S, a4,Q, f4,Ed, c5,S, a4,HALF]);
fwrite(serPort, [140, 1, 9, e5,Q, e5,Q, e5,Q, f5,Ed, c5,S, aes4,Q, f4,Ed, c5,S, a4,HALF]);
fwrite(serPort, [140, 2, 9, a5,Q, a4,Ed, a4,S, a5,Q, aes5,E, g5,E, ges5,S, f5,S, ges5,S]);
fwrite(serPort, [140, 3, 8, r,E, bes4,E, ees5,Q, d5,E, des5,E, c5,S, b4,S, c5,E]);
fwrite(serPort, [140, 4, 9, r,E, f4,E, aes4,Q, f4,Ed, aes4,S, c5,Q, a4,Ed, c5,S, e5,HALF]);
fwrite(serPort, [140, 5, 9, r,E, f4,E, aes4,Q, f4,Ed, c5,S,a4,Q, f4,Ed, c5,S, a4,HALF]);

fwrite(serPort, [141, 0]);
pause(MEASURE_TIME*2.01);

fwrite(serPort, [141, 1]);
pause(MEASURE_TIME*2.01);

fwrite(serPort, [141, 2]);
pause(MEASURE_TIME*1.26);

fwrite(serPort, [141, 3]);
pause(MEASURE_TIME*1.01);

fwrite(serPort, [141, 4]);
pause(MEASURE_TIME*1.76);

fwrite(serPort, [141, 2]);
pause(MEASURE_TIME*1.26);

fwrite(serPort, [141, 3]);
pause(MEASURE_TIME*1.01);

fwrite(serPort, [141, 5]);
pause(MEASURE_TIME*1.76);

