% runhtb() - Run history template on batch files.
%
%   This function opens a browser and prompts the user to select a history
%   template batching file ("*.htb"), then opens a second browser prompting
%   the user to select the data files on which to perform the history
%   tmplate batching. The runhtb function loops through the
%   htb file string as many times as there are files selected from the
%   browser, repalcing "BatchFName" with the file name of each new
%   iteration.
%
%   Note: this function is capable of overwriting files if the input and
%   output file extensions are not different. If the output file name in
%   the htb string is not replaced by "BatchFName" the out put of each
%   iteration will be written to the same file overwriting it each time.
%
% Usage:
%   >>  runhtb(HistFName,HistFPath,BatchFName,BatchFPath);

% Inputs:
%   HistFName    - Name of history template file.
%   HistFPath    - Path of history template file.
%   BatchFName   - Name of batch files.
%   BatchFPath   - Path of batch files.
%    
% Outputs:
%   Files written to hard drive.
%
% See also: 
%   savehtb, savedatsetbatch 

% Copyright (C) <2006>  <James Desjardins> <Brock University>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: runhtb.m edit history...
%

function runhtb(HistFName, HistFPath, BatchFName, BatchFPath)

disp(['current file: ' BatchFName ])

if nargin < 1
	help runhtb;
	return;
end;	

eval(['fidRHT=fopen(''' HistFPath HistFName ''',''r'');']);

HistStr=char(fread(fidRHT,'char')');

%swap HistStr keyPack strings...
% batch_dfn
HistStr=key_strswap(HistStr,'batch_dfn',BatchFName);
% batch_dfp
HistStr=key_strswap(HistStr,'batch_dfp',BatchFPath);
%current_dir
HistStr=key_strswap(HistStr,'batch_cd',cd);


HistStr

try
  evalin('base',HistStr)
catch
    sprintf('%s%s%s', 'Error while processing file "', BatchFName, '"... continued to next file.');
end
