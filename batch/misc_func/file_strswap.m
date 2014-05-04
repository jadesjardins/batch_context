function swapstr=file_strswap(fname,varargin)

strswap_struct=struct(varargin{:});
keystr=fieldnames(strswap_struct);
valstr=struct2cell(strswap_struct);


fid=fopen(fname,'r');
str=fread(fid,'char');
swapstr=char(str');

for i=1:length(keystr);
    swapstr=strrep(swapstr,keystr{i},valstr{i});
end
