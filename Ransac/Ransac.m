N_min =3;
i_max =100;
tau=0.2;
d=10;
nr_points=size(X,1)

set_R_cc=[]
set_x_cc=[]
set_y_cc=[]
set_I=[]

for i = 1:i_max
    I=[];
    R_cc_best=0;
    x_cc_best=0;
    y_cc_best=0;
    I_best=[];
    for j= 1:N_min
        rand_int = randi([1,nr_points],1,1);
        I = [I, rand_int];
    end
    if ( (Y(I(3)) - Y(I(2)))/(X(I(3)) - X(I(2))) ) == ( (Y(I(2)) - Y(I(1)))/(X(I(2)) - X(I(1))) ) continue
    else
        for j= 1:nr_points
            if ~any(I==j)
                sum_x = 0;
                for k= 1:size(I,2)
                    sum_x = sum_x + X(I(k));
                end
                x_cc = sum_x/size(I,2);
                sum_y = 0;
                for k= 1:size(I,2)
                    sum_y = sum_y + Y(I(k));
                end
                y_cc = sum_y/size(I,2);
                
                min_x = 10000;
                max_x = -10000;
                min_y = 10000;
                max_y = -10000;
                for k= 1:size(I,2)
                    if X(I(k))<min_x
                        min_x = X(I(k));
                    elseif X(I(k))>max_x
                        max_x = X(I(k));
                    end
                    
                    if Y(I(k))<min_y
                        min_y = Y(I(k));
                    elseif Y(I(k))>max_y
                        max_y = Y(I(k));
                    end
                end
                
                R_cc = sqrt( ((max_x-min_x)^2)/4 + ((max_y-min_y)^2)/4 );
                
                err = abs((X(j)-x_cc)^2 + (Y(j)-y_cc)^2 - R_cc^2);
                if err < tau
                    I = [I, j];
                end
            end
        end
    end
    
    if(size(I,2)>= d)
        if size(I,2) > size(I_best,2)
            sum_x=0;
            for k= 1:size(I,2)
                sum_x = sum_x + X(I(k));
            end
            x_cc = sum_x/size(I,2);
            sum_y = 0;
            for k= 1:size(I,2)
                sum_y = sum_y + Y(I(k));
            end
            y_cc = sum_y/size(I,2);
                
            min_x = 10000;
            max_x = -10000;
            min_y = 10000;
            max_y = -10000;
           for k= 1:size(I,2)
               if X(I(k))<min_x
                   min_x = X(I(k));
               elseif X(I(k))>max_x
                   max_x = X(I(k));
               end
                
               if Y(I(k))<min_y
                  min_y = Y(I(k));
               elseif Y(I(k))>max_y
                  max_y = Y(I(k));
               end
           end
                
           R_cc = sqrt( ((max_x-min_x)^2)/4 + ((max_y-min_y)^2)/4 );
                
           R_cc_best = R_cc;
           x_cc_best = x_cc;
           y_cc_best = y_cc;
           I_best = I;
        end
    end
end 

set_R_cc=[set_R_cc, R_cc_best];
set_x_cc=[set_x_cc,x_cc_best];
set_y_cc=[set_y_cc,y_cc_best];
set_I=[set_I,I_best];