input_file = 'LENA_FILTRATA_ERRORE.txt'; 
output_file = 'LENA_FILTRATA_ERRORE_MATRIX.txt'; 

data_vector = load(input_file);
matrix_transposed = reshape(data_vector, 32, 32)'; 

fid = fopen(output_file, 'w');
for i = 1:rows
    for j = 1:cols
        if j == cols
            fprintf(fid, '%d', matrix_transposed(i, j));
        else
            fprintf(fid, '%d ', matrix_transposed(i, j)); 
        end
    end
    fprintf(fid, '\n'); 
end

fclose(fid);