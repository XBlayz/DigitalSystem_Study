output_data = load('output_image.txt');

figure;
subplot(1,2,1);
imshow(uint8(reshape(load('lena32.txt'), 32, 32)'));
title('Immagine Originale');

subplot(1,2,2);
imshow(uint8(output_data));
title('Immagine Filtrata (Gaussiana)');