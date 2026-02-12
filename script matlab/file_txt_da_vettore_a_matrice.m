input_file = 'filtered_image1.txt'; 
output_file = 'filtered_image1_matrix.txt'; 
rows = 32;
cols = 32;

data_vector = load(input_file);
matrix_transposed = reshape(data_vector, rows, cols)'; 

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