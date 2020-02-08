A_c= imread('stripes_x.gif');

is_color= size(size(A_c),2) == 3;

if (is_color)
    A = rgb2gray(A_c);
else
    A= A_c;
end;

A = double(A)./255; % image
figure(1);
visualize_spectrum(A);

A_c= imread('stripes_y.gif');

is_color= size(size(A_c),2) == 3;

if (is_color)
    A = rgb2gray(A_c);
else
    A= A_c;
end;

A = double(A)./255;
figure(2);
visualize_spectrum(A);


A_c= imread('stripes_diagonal.jpg');

is_color= size(size(A_c),2) == 3;

if (is_color)
    A = rgb2gray(A_c);
else
    A= A_c;
end;

A = double(A)./255;
figure(3);
visualize_spectrum(A);


A_c= imread('checkerboard.gif');

is_color= size(size(A_c),2) == 3;

if (is_color)
    A = rgb2gray(A_c);
else
    A= A_c;
end;

A = double(A)./255;
figure(4);
visualize_spectrum(A);