close all;
clear all;

A_c= imread('turing.png');
A = rgb2gray(A_c);
A = double(A)./255; % image
figure(1);
visualize_spectrum(A);


sigma_spatial= 5;
B = fspecial('gaussian', [7*sigma_spatial 7*sigma_spatial], sigma_spatial);
figure(2);
visualize_spectrum(B);


[m,n] = size(A);
[mb,nb] = size(B); 

mm = m + mb - 1;
nn = n + nb - 1;

Af= fft2(A,mm,nn);
Bf= fft2(B,mm,nn);

C = ifft2(Af.* Bf);
figure(3)
imshow(C,[]);
title('Convolution done in Frequency Domain (Padded)');


padC_m = ceil((mb-1)./2);
padC_n = ceil((nb-1)./2);


D = C(padC_m+1:m+padC_m, padC_n+1:n+padC_n); 
figure(4);
title('Convolution done in Frequency Domain (Clipped Padding)');
visualize_spectrum(D);


F = conv2(A,B,'same');
figure(5); imshow(F,[]);
title('Convolution done in Spacial Domain');

error= norm(F - D)





