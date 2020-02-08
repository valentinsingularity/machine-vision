close all;
clear all;

L_c= imread('marilyn.bmp'); % 'dog.jpg'
is_color= size(size(L_c),2) == 3
L= L_c;
if (is_color)
    L = rgb2gray(L_c);
end;
L = double(L)./255;
figure(2);
visualize_spectrum(L);

H_c= imread('einstein.bmp'); % 'cat.jpg'
is_color= size(size(H_c),2) == 3
H= H_c;
if (is_color)
    H = rgb2gray(H_c);
end;
H = double(H)./255;
figure(1); 
visualize_spectrum(H);


[m,n] = size(L);

sigma_l= 15; 
figure(3); subplot(1,2,1);
LowPass_f = fspecial('gaussian', [m n], sigma_l); 
imshow(mat2gray(LowPass_f));  subplot(1,2,2);
LowPass_f = fftshift(LowPass_f); 
imshow(mat2gray(LowPass_f));


L_f= fft2(L,m,n);
Low_L_f= L_f.* LowPass_f;
C = ifft2(Low_L_f); 
figure(4); 
visualize_spectrum(real(C));
 

sigma_h= 15; 
HighPass = fspecial('gaussian', [m n], sigma_h);
HighPass_f = max(max(HighPass)) - HighPass;
HighPass_f = HighPass_f/sum(sum(HighPass_f));

figure(5);
imshow(mat2gray(log(1+abs(HighPass_f)))); 
HighPass_f = fftshift(HighPass_f); 


H_f= fft2(H,m,n);
High_H_f= H_f.* HighPass_f;



Ch= ifft2(High_H_f);
figure(6);
visualize_spectrum(real(Ch));


energy_l= norm(Low_L_f, 'fro')
energy_h= norm(High_H_f, 'fro')
weight= 0.1

Hybrid_f= Low_L_f + High_H_f .*(weight*(energy_l/energy_h)); 
Hybrid= real(ifft2(Hybrid_f));

figure(7); 
imshow(mat2gray(real(Hybrid)));
