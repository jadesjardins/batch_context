function pop_savebatchonfig(fname,fpath)


global BATCH_CONFIG

if isempty(BATCH_CONFIG);
    disp('There is no global option_batchcfg structure available to save.');
    return
else
    if nargin < 2;
        [fname,fpath]=uiputfile('*.cfg','Save batch configuration file:');
    end
    save(fullfile(fpath,fname),'BATCH_CONFIG');
end