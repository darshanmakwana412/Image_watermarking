PSNRs=0;
nccs=0;

wm = imread('./watermarks/10.png');

d='./imgs/';
files=dir(strcat(d,'*.png'));

for i = 1:size(files)
    imgPath=strcat(d,files(i).name);
    img = double(im2gray(imread(imgPath)));
    [PSNR,ncc]=ImageWatermarkingTester(img,wm);
    PSNRs=PSNRs+PSNR;
    nccs=nccs+ncc;
    disp(imgPath);
end

disp(PSNRs/4);
disp(nccs/4);

% Computes the normalized cross correlation for images I1 and I2
function normalized_cross_correlation = NCC(I1, I2)
    % Compute mean of both the images
    mean_I1 = mean(I1, "all");
    mean_I2 = mean(I2, "all");
    
    % Compute dot product of (I1 - mean_I1) and (I2 - mean_I2)
    num = sum((I1 - mean_I1).*(I2 - mean_I2), "all");
    den = sqrt(sum((I1 - mean_I1).^2, "all") * sum((I2 - mean_I2).^2, "all"));
    normalized_cross_correlation = abs(num/den);
end

function [PSNR, ncc] = ImageWatermarkingTester(I,watermark)
    [h, w] = size(I);
    bs = 1;
    cnt = 0;
    I1=I;
    watermark = double(imresize(watermark, [h, w]));
    
    for br = 1:(h-1)/bs
        for bc = 1:(w-1)/bs
    
            mask = bitshift(1, 0);
            I1((br - 1) * bs + 1 : br * bs, (bc - 1) * bs + 1 : bc * bs) = bitand(watermark((br - 1) * bs + 1 : br * bs, (bc - 1) * bs + 1 : bc * bs), mask) + bitand(I((br - 1) * bs + 1 : br * bs, (bc - 1) * bs + 1 : bc * bs), 255 - mask);
            cnt = cnt + 1;
        end
    end
        
    noisy_watermarked_barbara =  uint8(I1+0.05*randn(size(I1)));
    attacked_watermark = bitand(noisy_watermarked_barbara, 1);

    MSE = immse(I,I1);
    disp("MSE: " + MSE);
    PSNR = 10 * log10(255 * 255 / MSE);
    
    ncc = NCC(double(attacked_watermark), double(watermark));
end