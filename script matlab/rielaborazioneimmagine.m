output_data = load('file_txt_filtroconexcel/laureti.txt');
output_data(output_data > 255) = 255;
output_data(output_data < 0)   = 0;

immagine_filtrata = reshape(output_data, 32, 32);

figure;
subplot(1,2,1);
imshow(uint8(reshape(load('file_txt_originali/laureti.txt'), 32, 32)));
title('Immagine Originale');

subplot(1,2,2);
imshow(uint8(immagine_filtrata));
title('Immagine Filtrata (Gaussiana)');