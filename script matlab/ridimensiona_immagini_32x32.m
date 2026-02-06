% Scegli un'immagine standard
nome_file = 'figures/immagini_originali/laureti.png';

% 1. Leggi
img_original = imread(nome_file);

% 2. Converti in scala di grigi se necessario
if size(img_original, 3) == 3
    img_gray = rgb2gray(img_original);
else
    img_gray = img_original;
end

% 3. Ridimensiona a 32x32
img_32 = imresize(img_gray, [32 32]);

% 4. Visualizza per controllo
figure;
subplot(1,2,1); imshow(img_gray); title('Originale');
subplot(1,2,2); imshow(img_32); title('Ridimensionata 32x32');

imwrite(img_32, 'figures/immagini_originali/laureti_32x32.png');

% 5. Salva la matrice nel file per il VHDL
fid = fopen('file_txt_originali/laureti.txt', 'w');
for i = 1:32
    for j = 1:32
        fprintf(fid, '%4d ', double(img_32(i, j)));
    end
    fprintf(fid, '\n');
end
fclose(fid);
