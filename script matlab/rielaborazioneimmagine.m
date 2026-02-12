output_data = load('filtered_image1_matrix.txt');
% output_data(output_data > 255) = 255;
% output_data(output_data < 0)   = 0;
output_data = output_data/16;

immagine_filtrata = reshape(output_data, 32, 32);

imshow(uint8(immagine_filtrata));
title('Immagine Filtrata (Gaussiana)');