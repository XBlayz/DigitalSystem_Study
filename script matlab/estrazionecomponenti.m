
a=imread('figures/immagini_originali/scacchiera.png');
imshow(a);
b=im2gray(a);
imshow(b);
im=b';
imc=reshape(im,1024,1);
 file_write=['file_txt_originali/originali_vettore/scacchiera_vettore.txt'];
    fid_T = fopen(file_write,'w');
    fprintf(fid_T,'%d\n',double(imc));
    fclose(fid_T);