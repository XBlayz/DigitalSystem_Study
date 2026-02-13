
input_file = 'filtered_image.txt'; 
output_file = 'filtered_image_matrix.txt'; 
rows = 32;
cols = 32;

data_vector = load(input_file);


data_vector_norm = round(data_vector / 16);
data_vector_norm(data_vector_norm > 255) = 255; % saturazione max
data_vector_norm(data_vector_norm < 0) = 0;     % saturazione min IN TEORIA NON SERVE

rendi_matrice(data_vector_norm, rows, cols, output_file);

elabora_immagine(output_file);


function rendi_matrice(vettore, righe, colonne, file_output)
    matrice_ordinata = reshape(vettore, righe, colonne)'; 
    fid = fopen(file_output, 'w');
    for i = 1:righe
        for j = 1:colonne
            if j == colonne
                fprintf(fid, '%d', matrice_ordinata(i, j));
            else
                fprintf(fid, '%d ', matrice_ordinata(i, j)); 
            end
        end
        fprintf(fid, '\n'); 
    end
    fclose(fid);
end

function elabora_immagine(nome_file)
    matrice_caricata = load(nome_file);
    figure;
    imshow(uint8(matrice_caricata));
    title('Immagine Filtrata (Gaussiana) Normalizzata');
    
    % Verifica dimensioni nella console
    disp('Dimensione immagine caricata:');
    disp(size(matrice_caricata));
end