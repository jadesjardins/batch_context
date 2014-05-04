function inStr=key_strswap(inStr,keyStr,swapStr)

n_skip=1;

while length(strfind(inStr,keyStr))>=n_skip;
    
    i1=strfind(inStr,keyStr);
    i=i1(n_skip);
    
    %look for preceding "prepack" '[' without adjoining ']'...
    i1m1=[];
    prepack={};
    while isempty(i1m1);
        i=i-1;
        if i<1;break;end
        if strcmp(inStr(i),'[');
            i1m1=i;
            if isempty(strfind(inStr(i1m1:i1(n_skip)),']'));
                if i1(n_skip)-i>1;
                    c_ind=strfind(inStr(i1m1+1:i1(n_skip)-1),',');
                    if length(c_ind==2)
                        prepack{1}=strtrim(inStr(i1m1+1:i1m1+c_ind(1)-1));
                        prepack{2}=str2num(strtrim(inStr(i1m1+c_ind(1)+1:i1m1+c_ind(2)-1)));
                    end
                end
            end
        end
    end
    
    
    %look for following "postpack" ']' without adjoining '['...
    i2=i1(n_skip)+length(keyStr)-1;
    i=i2;
    i2p1=[];
    postpack={};
    while isempty(i2p1);
        i=i+1;
        if i>length(inStr);break;end
        if strcmp(inStr(i),']');
            i2p1=i;
            if isempty(strfind(inStr(i2+1:i2p1-1),'['));
                if i-i2>1;
                    c_ind=strfind(inStr(i2+1:i2p1-1),',');
                    if length(c_ind==2)
                        postpack{1}=strtrim(inStr(i2+c_ind(1)+1:i2+c_ind(2)-1));
                        postpack{2}=str2num(strtrim(inStr(i2+c_ind(2)+1:i2p1-1)));
                    end
                end
            end
        end
    end
    
    %perform the swap...
    if isempty(prepack)&&isempty(postpack);
        if strcmp(inStr(i1(n_skip)-1),'[')&&strcmp(inStr(i2+1),']')
            keyPack=inStr(i1(n_skip)-1:i2+1);
            inStr=strrep(inStr,keyPack,swapStr);
        else
            n_skip=n_skip+1;
        end
    else
        keyPack=inStr(i1m1:i2p1);

        if isempty(prepack)
            startInd=1;
        else
            preInds=[];
            preInds=strfind(swapStr,prepack{1});
            n_preInds=length(preInds);
            if prepack{2}>0;
                preInds_ind=prepack{2};
            else
                preInds_ind=n_preInds+1+prepack{2};
            end
            startInd=preInds(preInds_ind)+1;
        end

        if isempty(postpack)
            endInd=length(swapStr);
        else
            postInds=[];
            postInds=strfind(swapStr,postpack{1});
            n_postInds=length(postInds);
            if postpack{2}>0;
                postInds_ind=postpack{2};
            else
                postInds_ind=n_postInds+1+postpack{2};
            end
            endInd=postInds(postInds_ind)-1;
        end

        
        swapStr_root=swapStr(startInd:endInd);
        inStr=strrep(inStr,keyPack,swapStr_root);
    end
end

