a = imread('lena32.jpg');

b = rgb2gray(a);

[rows, cols] = size(b);

file_write = 'lena32_matrix.txt';
fid_T = fopen(file_write, 'w');

for i = 1:rows
    for j = 1:cols
        fprintf(fid_T, '%4d ', double(b(i, j)));
    end
    fprintf(fid_T, '\n');
end

fclose(fid_T);

disp(['File ', file_write, ' creato con successo come matrice 32x32.']);