%Reading the input Fabric Image   

I=imread('Fabric16.jpg');
figure
imshow(I,[]);

%% RGB to gray Conversion

RGBImage=rgb2gray(I);
%scaling = 512/m;
%RGBImage=imresize(RGBImage,scaling,'nearest');
%disp(size(RGBImage));
figure
subplot(2,2,1),imshow(RGBImage,[]);
title('rgb image');

%% Applying gaussian smoothening to reduce noise in the image

RGBImage = imgaussfilt(RGBImage,1);
imageSize = size(RGBImage);
numRows = imageSize(1);
numCols = imageSize(2);

%% Setting Gabor Parameters to create the Gabor filter. 
%% Wavelength and Orientation to set in the gabor Filter.
%% We are using four orientations in the filter that we are using one is 0, 45,90 and 135

wavelengthMin = 4/sqrt(2);
wavelengthMax = hypot(numRows,numCols);
n = floor(log2(wavelengthMax/wavelengthMin));
wavelength = 2.^(0:(n-2)) * wavelengthMin;
deltaTheta = 45;
orientation = 0:deltaTheta:(180 - deltaTheta);
g = gabor(wavelength,orientation);

%% Putting the gabor object in gabor filter function along with the image. 
%% Putting the threshold of image as (max pixel + minpixel)/2 
%% Applying Gabor filter on four orientations at 0, 45,90,135 gives indications of the defects along these 4 angles.
%% After adding all the 4 images to get the combined defect. Apply the threshold on this image. If pixel> threshold 
%% set the pixel=255 else set pixel =0 

[output,o]=imgaborfilt(uint8(RGBImage),g);
% figure
H=zeros(512,512);
for p=1:4
   % subplot(2,2,p)
    I1=output(:,:,p);
    X = reshape(I1,[1,512*512]);
    a = max(X);
    b = min(X);
    for i =1:511
        for j=1:511
            if (I1(i,j)>(a+b)/2)
                I1(i,j)=255;
            else 
                I1(i,j)=0;
            end
            H(i,j)=H(i,j)+I1(i,j);
        end
    end
    
    %% Apply Otsu Algorithm to binarize the image using the graythresh function 
    T = graythresh(I1);
    imbinarize(I1,T);
   % title('binary image');
  %  title(sprintf('Image Number=%d',p));
end
%figure
%subplot(2,2,2),imshow(uint8(H));
%title('gabor filter');

%% Apply closing(Dilation + erosion) on the defect detected image to remove the unnecessary part to remove not so relevant defects in the image. 
%% The structuring element used is a 3 radius ball. 

se = offsetstrel('ball',3,3);
a= imerode(H,se);
a=imdilate(a,se);
subplot(2,2,2),imshow(uint8(a));
title('gabor filter');
%% On the final defect detection of image apply the canny filter to detect defect of the image and seperate it from the background

EdgeDetect=edge(a,'canny');
%figure
subplot(2,2,3),imshow((EdgeDetect));
title('edge detected image');
%% Once the edge is detected around the Fabric we colour the edge as red colour by RGB colouring. 
%% And we superimpose this edge around the original fabric image  

for i =1:512
    for j=1:512
        if(EdgeDetect(i,j)>0)
                I(i, j, 1) = 255;
                I(i, j, 2) = 0;
                I(i, j, 3) = 0;
        end
    end
end

% figure
% imshow(uint8(I));

%% Finally we apply the box filter to remove the breaks in edges after canny edge detection 
%% We apply a box filter of dimensions 3*3 

finalOutput=imboxfilt(I,3);
%figure
subplot(2,2,4),imshow(uint8(finalOutput));
title('final defect detected image');