function Grid = Tblock_getgridout_1(fname)

fid=fopen(fname,'r');
dum=fread(fid,1,'int32');
Grid.nblocks=fread(fid,1,'int32');
dum=fread(fid,1,'int32');
for nblck=1:Grid.nblocks,
    dum=fread(fid,1,'int32');
    Grid.block(nblck).im=fread(fid,1,'int32');
    Grid.block(nblck).jm=fread(fid,1,'int32');
    Grid.block(nblck).km=fread(fid,1,'int32');
    dum=fread(fid,1,'int32');
    im=Grid.block(nblck).im;
    jm=Grid.block(nblck).jm;
    km=Grid.block(nblck).km;
    %
    Grid.block(nblck).x=zeros(im,jm,km);
    Grid.block(nblck).r=zeros(im,jm,km);
    Grid.block(nblck).rt=zeros(im,jm,km);
    %   
    for i=1:im,
        for j=1:jm,
            %
            dum=fread(fid,1,'int32');
            Grid.block(nblck).x(i,j,:)=fread(fid,km,'real*4');
            dum=fread(fid,1,'int32');
            %
            dum=fread(fid,1,'int32');
            Grid.block(nblck).r(i,j,:)=fread(fid,km,'real*4');
            dum=fread(fid,1,'int32');
            %
            dum=fread(fid,1,'int32');
            Grid.block(nblck).rt(i,j,:)=fread(fid,km,'real*4');
            dum=fread(fid,1,'int32');
            %
        end
    end    
end
fclose(fid);

