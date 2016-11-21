% % pop_linked2() - Gratton ocular correction. Apply the function to
%                epoched data and use it separately for the realized
%                experimental conditions.
%                If less than two arguments are given, a window pops up
%                to ask for the value of the additional parameters.   
%
% Usage:
%   >>  OUTEEG = pop_linked2( INEEG, new_mast, 'key', 'value',...);
%
% Inputs:
%   INEEG   - input EEG dataset
%   new_mast - channel number of EOG channel used for the correction
%
% Opts:
%    chans        - select which channels are to be corrected; []=all
%    blinkcritwin - time window for criterion (in ms)  
%    blinkcritvolt- criterion for blink detection:
%                   (EOG(t) - EOG(t-win)) + (EOG(t) - EOG(t+win)) >= crit
%
%
% Outputs:
%   OUTEEG  - output dataset
%
% See also:
%   EEGLAB 

% Copyright (C) 2007  Matthias Ihrke <mihrke@uni-goettingen.de>
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
%
% $Log: pop_linked.m,v $
% Revision 1.1  2007/06/22 12:29:29  mihrke
% added a lot of analysis scripts for exp 6
%
%

function [EEG, com] = pop_linked( EEG, new_mast, channels );

% the command output is a hidden output that does not have to
% be described in the header

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            


%non essendoci help cancello le successive linee
%isplay help if not enough arguments
%------------------------------------
if nargin < 1
	help pop_linked;
	return;
end;	

% cmd-line parsing
args = varargin;
% create structure
% ----------------
if ~isempty(args)
   try, g = struct(args{:});
   catch, disp('pop_linked(): wrong syntax in function arguments'); return; end;
else
    g = [];
end;

% test the presence of variables
% ------------------------------
try, g.chans;              catch, g.chans=1:EEG.nbchan; end;
%try, g.blinkcritwin;       catch, g.blinkcritwin=20; end;
%try, g.blinkcritvolt;      catch, g.blinkcritvolt=200; end;


%qui dovresti mettere una riga che invece testa se il file  continuo
%assert(~isempty(EEG.epoch),' Error: pop_linked(): Ocular correction can only be applied to epoched data');

if nargin < 2 
	% popup window parameters
	% -----------------------
    	% -----------------
   	uilist = { ...
        { 'style' 'text' 'string' 'Other reference Channel:' } ...
        { 'style' 'edit' 'string' '' } ...
        { 'style' 'text' 'string' 'Exclude these Chans from the re-ref:' } ...
        { 'style' 'edit' 'string' '' } ...        
     };
    geometry = [ 2 2 ];
    
    result = inputgui( 'geometry', geometry, 'uilist', uilist, 'title', 'Re-reference to average mastoids -- pop_linked()', ...
	'helpcom', 'pophelp(''pop_linked'')');
    

    new_mast = eval(result{1});
    %g.chans = eval(result{2});
g.chans = eval(sprintf('[ %s ]', result{2}));
    %if isempty(g.chans) 
     %   g.chans = 1:EEG.nbchan;end;
end;

[EEG] = linked(EEG, new_mast, g.chans)

%[el times trials] = size(EEG.data);
%step = 1000/EEG.srate; % sampling step in ms
%EEG.data(g.chans,:,:) = gratton(EEG.data(g.chans,:,:),...
%    reshape(EEG.data(new_mast,:,:), [times trials]),...
%    g.blinkcritvolt, g.blinkcritwin/step);

% return the string command
% ------------------------
com = sprintf('EEG.data = pop_linked( EEG,''new_mast'',[%p] );', new_mast,...
    num2str(g.chans));

%return;
