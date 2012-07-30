function Flow = Tblock_getflowout_1(fname)
%Function loads in a tblock output file and outputs the flow conditions for
%all blocks in structure Flow

%Load in File
fid=fopen(fname,'r');
dum=fread(fid,1,'int32');
Flow.nblocks=fread(fid,1,'int32')
dum=fread(fid,1,'int32');
dum=fread(fid,1,'int32');
Flow.cp=fread(fid,1,'real*4');
Flow.ga=fread(fid,1,'real*4');
dum=fread(fid,1,'int32');
for nblck=1:Flow.nblocks,
    dum=fread(fid,1,'int32');
    Flow.block(nblck).im=fread(fid,1,'int32');
    Flow.block(nblck).jm=fread(fid,1,'int32');
    Flow.block(nblck).km=fread(fid,1,'int32');
    dum=fread(fid,1,'int32');
    im=Flow.block(nblck).im;
    jm=Flow.block(nblck).jm;
    km=Flow.block(nblck).km;
    %
    Flow.block(nblck).ro=zeros(im,jm,km);
    Flow.block(nblck).rovx=zeros(im,jm,km);
    Flow.block(nblck).rovr=zeros(im,jm,km);
    Flow.block(nblck).rorvt=zeros(im,jm,km);
    Flow.block(nblck).roe=zeros(im,jm,km);
    Flow.block(nblck).spare=zeros(im,jm,km);
    %   
    for i=1:im,
        for j=1:jm,
            %
            dum=fread(fid,1,'int32');
            Flow.block(nblck).ro(i,j,:)=fread(fid,km,'real*4');
            dum=fread(fid,1,'int32');
            %
            dum=fread(fid,1,'int32');
            Flow.block(nblck).rovx(i,j,:)=fread(fid,km,'real*4');
            dum=fread(fid,1,'int32');
            %
            dum=fread(fid,1,'int32');
            Flow.block(nblck).rovr(i,j,:)=fread(fid,km,'real*4');
            dum=fread(fid,1,'int32');
            %
            dum=fread(fid,1,'int32');
            Flow.block(nblck).rorvt(i,j,:)=fread(fid,km,'real*4');
            dum=fread(fid,1,'int32');
            %
            dum=fread(fid,1,'int32');
            Flow.block(nblck).roe(i,j,:)=fread(fid,km,'real*4');
            dum=fread(fid,1,'int32');
            %
            dum=fread(fid,1,'int32');
            Flow.block(nblck).spare(i,j,:)=fread(fid,km,'real*4');
            dum=fread(fid,1,'int32');
            %
        end
    end    
    dum=fread(fid,1,'int32');
    Flow.block(nblck).wrot=fread(fid,1,'real*4');
    Flow.block(nblck).timtot=fread(fid,1,'real*4');
    dum=fread(fid,1,'int32');

   

end
fclose(fid);

