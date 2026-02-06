
a=imread('lena32.jpg');
imshow(a);
b=rgb2gray(a);
imshow(b);
im=b';
imc=reshape(im,1024,1);
 file_write=['lena32_matrix.txt'];
    fid_T = fopen(file_write,'w');
    fprintf(fid_T,'%d\n',double(imc));
    fclose(fid_T);