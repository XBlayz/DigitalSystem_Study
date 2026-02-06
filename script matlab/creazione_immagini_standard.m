
dim = 32;

% QUADRATO
img_square = zeros(dim, dim);
img_square(10:22, 10:22) = 255; 

% STRISCIA VERTICALE
img_stripe = zeros(dim, dim);
img_stripe(:, 17:end) = 255;

% SCACCHIERA
img_checker = checkerboard(8, 2, 2) > 0.5;
img_checker = double(img_checker) * 255;
img_checker = imresize(img_checker, [32 32], 'nearest');

figure('Name', 'Pattern di Test', 'NumberTitle', 'off');
subplot(1,3,1); imshow(uint8(img_square)); title('Quadrato');
subplot(1,3,2); imshow(uint8(img_stripe)); title('Striscia');
subplot(1,3,3); imshow(uint8(img_checker)); title('Scacchiera');

salva_matrice(img_square, fullfile('file_txt_originali/immagine_test_quadrato.txt'));
imwrite(uint8(img_square), fullfile('figures/immagini_originali/quadrato.png'));
salva_matrice(img_stripe, fullfile('file_txt_originali/immagine_test_striscia.txt'));
imwrite(uint8(img_stripe), fullfile('figures/immagini_originali/striscia.png'));
salva_matrice(img_checker, fullfile('file_txt_originali/immagine_test_scacchiera.txt'));
imwrite(uint8(img_checker), fullfile('figures/immagini_originali/scacchiera.png'));

function salva_matrice(img, percorso_completo)
    fid = fopen(percorso_completo, 'w'); 
    [rows, cols] = size(img);
    for i = 1:rows
        for j = 1:cols
            fprintf(fid, '%4d ', round(img(i, j)));
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end
