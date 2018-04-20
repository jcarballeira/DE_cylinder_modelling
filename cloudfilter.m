function nube_mat=cloudfilter(ptCloud)

xyz=ptCloud.Location;
xyz=reshape(xyz, [1 size(xyz,1)*size(xyz,2)]);
xyz(isnan(xyz))=[];
sz=size(xyz,2);
mat=zeros(3,sz/3);   
for j=1:1:sz/3
       x=xyz(j);
       y=xyz(j+sz/3);
       z=xyz(j+2*sz/3);
       mat(:,ceil(j)) = [x y z]';
end
nube_mat=double(mat);

end