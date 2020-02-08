clear all;

vidObj = VideoReader('videos/cars_at_an_intersection_hirez.mp4');
vidHeight = vidObj.Height
vidWidth = vidObj.Width

vidWriter = VideoWriter('cars_at_an_intersection_optical_flow.avi');
vidWriter.FrameRate = 0.75*vidObj.FrameRate;
open(vidWriter);


while hasFrame(vidObj)
    
    ORIGINAL_IMAGE_COL_1= readFrame(vidObj);
    ORIGINAL_IMAGE_COL_2= readFrame(vidObj);

    ORIGINAL_IMAGE_1=im2double(rgb2gray(ORIGINAL_IMAGE_COL_1));
    ORIGINAL_IMAGE_2=im2double(rgb2gray(ORIGINAL_IMAGE_COL_2));
    
    [height,width]=size(ORIGINAL_IMAGE_1);
    
    gauss_sigma = 1;
    IMAGE_1_SMOOTHED=zeros(height,width);
    IMAGE_2_SMOOTHED=zeros(height,width);
    
    %derivate variables
    Dx_1=zeros(height,width);
    Dy_1=zeros(height,width);
    Dx_2=zeros(height,width);
    Dy_2=zeros(height,width);
    
    Ix=zeros(height,width);
    Iy=zeros(height,width);
    It=zeros(height,width);
    
    
    %optical flow variables
    neighborhood_size=5;
    A=zeros(2,2);
    B=zeros(2,1);
    
    %kernel Variables:
    Kernel_Size = 6*gauss_sigma+1;
    k = (Kernel_Size-1)/2;
    gauss_kernel_x=zeros(Kernel_Size,Kernel_Size);
    gauss_kernel_y=zeros(Kernel_Size,Kernel_Size);
    kernel=zeros(Kernel_Size,Kernel_Size);
    
    for i=1:Kernel_Size
        for j=1:Kernel_Size
            gauss_kernel_x(i,j) = -( (j-k-1)/( 2* pi * gauss_sigma^3 ) ) * exp ( - ( (i-k-1)^2 + (j-k-1)^2 )/ (2*gauss_sigma^2) );
        end
    end
    
	
    for i=1:Kernel_Size
        for j=1:Kernel_Size
            gauss_kernel_y(i,j) = -( (i-k-1)/( 2* pi * gauss_sigma^3 ) ) *  exp ( - ( (i-k-1)^2 + (j-k-1)^2 )/ (2*gauss_sigma^2) );
        end
    end
      
    %compute x and y derivates for both images 
    Dx_1 = conv2(gauss_kernel_x,ORIGINAL_IMAGE_1);
    Dy_1 = conv2(gauss_kernel_y,ORIGINAL_IMAGE_1);
    Dx_2 = conv2(gauss_kernel_x,ORIGINAL_IMAGE_2);
    Dy_2 = conv2(gauss_kernel_y,ORIGINAL_IMAGE_2);
    
    
    Ix = (Dx_1 + Dx_2) / 2;
    Iy = (Dy_1 + Dy_2) / 2;
    
    
    %build a gaussian kernel to smooth images for computing It
    for i=1:Kernel_Size
        for j=1:Kernel_Size
            kernel(i,j) = (1/(2*pi*(gauss_sigma^2))) * exp (-((i-k-1)^2 + (j-k-1)^2)/(2*gauss_sigma^2));
        end
    end
    
    IMAGE_1_SMOOTHED = conv2(kernel,ORIGINAL_IMAGE_1);
    IMAGE_2_SMOOTHED = conv2(kernel,ORIGINAL_IMAGE_2);
    
    C1 = corner(ORIGINAL_IMAGE_1, 'MinimumEigenvalue'); 
    It = IMAGE_2_SMOOTHED - IMAGE_1_SMOOTHED;
    
    v_x= zeros(size(C1,1),1);
    v_y= zeros(size(C1,1),1);
    
    for c_ix= 1: size(C1, 1)
        i= C1(c_ix, 2);
        j= C1(c_ix, 1);
        A=zeros(2,2);
        B=zeros(2,1);
        
        for m=i-floor(neighborhood_size/2):i+floor(neighborhood_size/2)
            for n=j-floor(neighborhood_size/2):j+floor(neighborhood_size/2)
                if (m < 1) | (m > height) | (n < 1) | (n > width)
                    continue;
                end
                A(1,1)=A(1,1) + Ix(m,n)*Ix(m,n);
                A(1,2)=A(1,2) + Ix(m,n)*Iy(m,n);
                A(2,1)=A(2,1) + Ix(m,n)*Iy(m,n);
                A(2,2)=A(2,2) + Iy(m,n)*Iy(m,n);
                
                B(1,1)=B(1,1) + Ix(m,n)*It(m,n);
                B(2,1)=B(2,1) + Iy(m,n)*It(m,n);
                
            end
        end
        
        A_w=imgaussfilt(A,1);
        B_w=imgaussfilt(B,1);
        A_w_inv= pinv(A_w);
        result= A_w_inv*(-B_w);
        v_x(c_ix)= result(1,1);
        v_y(c_ix)= result(2,1);
    end
    
    imshow(ORIGINAL_IMAGE_COL_1);
    hold on;
    quiver(C1(:,1), C1(:,2), v_x, v_y, 1,'r');
    img_frame= getframe;
    writeVideo(vidWriter, img_frame);
    
    pause(1/vidObj.FrameRate);

end

close(vidWriter);