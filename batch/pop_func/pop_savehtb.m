% pop_savehtb() - Save current dataset history as a template file.
%
%   Saves the current dataset's history field to a text editable file with
%   the extension "htb" (History Template Batching file). The history
%   template batching file is a text file containing an EEGLAB dataset
%   history that has been formated to be applied to several data files
%   sequentially. The formatting of the history template batching files
%   revolve around the input and output file names. More specifically, the
%   file names are replaced with "[batch_dfn]" [batch Data File Name] (eg. "InputFName.raw" =
%   "batch_dfn"). The file path string in the history template batch file
%   is replaced with "[batch_dfp]" [batch Data File Path].
%
%   Example dataset history conveted to htb format. This example loads an
%   existing dataset, performs ICA then saves the output to the hard drive:
%
%   dataset history =
%
%   EEG = pop_loadset( 'filename', '26CP - FHO.cat2.set', 'filepath', 'C:\\Research\\BUCANL\\UW06\\EmotionalFHO\\ICA\\Exploration\\Drafts\\InterpTest\\');
%   EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
%   pop_SaveDatasetBatch( EEG, '26CP - FHO.cat2.set', 3, 'ica.set' );
%   pop_savehtb( EEG, 'DefaultICA.htb', 'C:\Research\BUCANL\UW06\EmotionalFHO\ICA\Exploration\Drafts\InterpTest\');
%
%   resulting htb file string =
%
%   EEG = pop_loadset( 'filename', 'BatchFName', 'filepath', 'BatchFPath');
%   EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
%   pop_SaveDatasetBatch( EEG, 'BatchFName', 3, 'ica.set' );
%
%
%   Note:
%
%   1 - Running history template batch files that contain [batch_dfn] as the 
%       input file name and the output file name will overwrite the data wihout
%       asking for permission.
%   3 - While the savehtb function attempts to format the current dataset
%       history to be compatible with the runhtb function, it
%       is advised to look over the htb file before batching procedures with
%       the pop_runhtb function. Some input values may need
%       to be replaced with variable names (eg. If input files have varying
%       numbers of channels a pop_function that requires as input the index
%       of the last channel will by default list the channel index, say "129".
%       In the htb file the "129" index value should be changed to the 
%       variable name "EEG.nbchan").
%   4 - This function will only recognize the input file name from specific
%       data loading functions. the currently recognized load functions are;
%       pop_loadset, pop_readegi, pop_loadbv, pop_loadcnt or pop_ImportERPscoreFormat.
%
%
% Usage:
%   >>  savehtb( EEG, FileName, PathName );

% Inputs:
%   EEG         - EEG dataset.
%   FileName    - Name of template file.
%   PathName    - Path of template file.
    
% Outputs:
%   write *.htb file to disk.
%
% See also: 
%   pop_savehtb, runhtb 

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


function com = pop_savehtb(EEG, FileName, FilePath)

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            

% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_savehtb;
	return;
end;	

% pop up window
% -------------
if nargin < 2
    [FileName, FilePath] = uiputfile('*.htb','Save history template batch file as:','HistoryTemplate.htb');
end;
if isnumeric(FileName);return;end

% call function sample either on raw data or ICA data
% ---------------------------------------------------
%savehtb(EEG, FileName, FilePath);

% return the string command
% -------------------------
com = sprintf('pop_savehtb( %s, ''%s'', ''%s'');', inputname(1), FileName, FilePath);

%% Create "HistStr" from EEG.history.
HistStr=sprintf('%s',EEG.history);

%% find the last call to "pop_loadset" in "HistStr" and make that the new starting point.
Index_loadset=findstr(HistStr,'EEG = pop_loadset');
if ~isempty(Index_loadset);
    HistStr=HistStr(Index_loadset(length(Index_loadset)):length(HistStr));
end
HistStr=strtrim(HistStr);

%% Create "LoadLine"
LoadLine=HistStr(1:find(double(HistStr)==10,1));
LoadLineSQuotes=strfind(LoadLine,'''');

%% Create "LoadFName", "RootFName" and "LoadFPath".

%loadset
if ~isempty(strfind(LoadLine,'EEG = pop_loadset'));
    LoadFName=LoadLine(LoadLineSQuotes(3)+1:LoadLineSQuotes(4)-1);
    LoadFPath=LoadLine(LoadLineSQuotes(7)+1:LoadLineSQuotes(8)-1);
end
%readegi
if ~isempty(strfind(LoadLine,'EEG = pop_readegi'));
    LoadFPathFName=LoadLine(LoadLineSQuotes(1)+1:LoadLineSQuotes(2)-1);
    [fpath,fname,fext]=fileparts(LoadFPathFName);
    LoadFName=[fname,fext];
    LoadFPath=fpath;
end
%loadbv
if ~isempty(strfind(LoadLine,'EEG = pop_loadbv'));
    LoadLine=strcat(LoadLine(1:find(LoadLine=='[',1,'first')-3), LoadLine(find(LoadLine==')',1,'last'):length(LoadLine)));
    HistStr=HistStr(find(double(HistStr)==10):length(HistStr));
    HistStr=strcat(LoadLine,HistStr);
    LoadFName=LoadLine(LoadLineSQuotes(3)+1:LoadLineSQuotes(4)-1);
    LoadFPath=LoadLine(LoadLineSQuotes(1)+1:LoadLineSQuotes(2)-1);
end
%ERPscore
if ~isempty(strfind(LoadLine,'pop_ImportERPscoreFormat'))||~isempty(strfind(LoadLine,'pop_ImportMULFormat'));
    LoadFName=LoadLine(LoadLineSQuotes(1)+1:LoadLineSQuotes(2)-1);
    LoadFPath=LoadLine(LoadLineSQuotes(3)+1:LoadLineSQuotes(4)-1);
end
%loadcnt
if ~isempty(strfind(LoadLine,'EEG = pop_loadcnt'));
    LoadFPathFName=LoadLine(LoadLineSQuotes(1)+1:LoadLineSQuotes(2)-1);
    [fpath,fname,fext]=fileparts(LoadFPathFName);
    LoadFName=[fname,fext];
    LoadFPath=fpath;
end
%biosig
if ~isempty(strfind(LoadLine,'EEG = pop_biosig'));
    LoadFPathFName=LoadLine(LoadLineSQuotes(1)+1:LoadLineSQuotes(2)-1);
    [fpath,fname,fext]=fileparts(LoadFPathFName);
    LoadFName=[fname,fext];
    LoadFPath=fpath;
end
    

%% Edit "HistStr" to allow batch sting replacment.
HistStr=strrep(HistStr,LoadFPath,'[batch_dfp]');
HistStr=strrep(HistStr,LoadFName,'[batch_dfn]');

%Replace strings containing '.' roots of the LoadFName...
lfn_pind=strfind(LoadFName,'.');
for i=1:length(lfn_pind);
    lfn_p_name{i}=LoadFName(1:lfn_pind(length(lfn_pind)-(i-1))-1);
    HistStr=strrep(HistStr,lfn_p_name{i},['[batch_dfn,.,-', num2str(i),']']);
end

%Replace strings containing '_' roots of the LoadFName...
lfn_uind=strfind(LoadFName,'_');
for i=1:length(lfn_uind);
    lfn_u_name{i}=LoadFName(1:lfn_uind(length(lfn_uind)-(i-1))-1);
    HistStr=strrep(HistStr,lfn_u_name{i},['[batch_dfn,_,-', num2str(i),']']);
end

%Replace instances of current directory...
currentDir=cd;
HistStr=strrep(HistStr,currentDir,'[batch_cd]');


%% Write "HistStr" in "*.htb" file to disk.
eval(['fidHTB=fopen(''' FilePath FileName ''',''w'');'])
fprintf(fidHTB, '%s', HistStr);
fclose(fidHTB);


