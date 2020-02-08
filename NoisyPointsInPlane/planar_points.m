% import cv_planar_points.txt as a matrix in variable R, range: A2:C442

n = 441   %number of points

r_g = sum(R)/n   % sum(R) - sum of the columns of R

S=zeros(3,3)    % initialize scatter matrix

for i = 1:n
S = S + (R(i,:)-r_g)'*(R(i,:)-r_g);  % compute scatter matrix
end

[eigen_vect,eigen_val] = eig(S)  % eigenvalue 1 is the minimum eigenvalue

n_plane = eigen_vect(:,1)   % normal unit vector to the plane

d = r_g*n_plane   % shortest distance to the origin