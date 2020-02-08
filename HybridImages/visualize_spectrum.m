function visualize_spectrum(B)

subplot(1,2,1)
imshow(B, [])
title ('Image (x,y)');

Bf= fft2(B);
Bf = fftshift(Bf);

Bf = abs(Bf);
Bf = log(Bf+1);

Bf = mat2gray(Bf);
subplot(1,2,2)
imshow(Bf, []);
title ('Spectrum log(|F(u,v)| + 1)');
